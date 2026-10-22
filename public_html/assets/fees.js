document.addEventListener('DOMContentLoaded', () => {
  const page = document.querySelector('.page-content');
  const dialog = document.querySelector('#fee-reversal-dialog');
  const money = n => Number(n || 0).toLocaleString('en-KE', {minimumFractionDigits: 2, maximumFractionDigits: 2});
  const notice = (message, ok = false, parent = page) => {
    const el = document.createElement('div'); el.className = `notice ${ok ? 'success' : 'error'}`;
    el.setAttribute('role', ok ? 'status' : 'alert'); el.textContent = message; parent.prepend(el);
    setTimeout(() => el.remove(), 7000);
  };
  const form = [...document.querySelectorAll('form.note-form')].find(f => f.elements.namedItem('entry_type'));
  let saving = false;
  function addLedgerRow(entry, label = null, reason = null) {
    let table = document.querySelector('table');
    if (!table) {
      const history = [...document.querySelectorAll('.content-section')].find(s => s.querySelector('h2')?.textContent.includes('Ledger entries'));
      const empty = history?.querySelector('.empty-state'); empty?.remove();
      table = document.createElement('table'); table.innerHTML = '<thead><tr><th>Date</th><th>Year / term</th><th>Entry</th><th>Description</th><th>Amount</th><th>Method / reference</th><th>Recorded by</th><th>Action</th></tr></thead><tbody></tbody>';
      const wrap = document.createElement('div'); wrap.className = 'table-wrap'; wrap.append(table); history?.append(wrap);
    }
    const row = document.createElement('tr'); row.dataset.ledgerRow = ''; row.dataset.entryId = entry.id;
    row.dataset.entryType = entry.entry_type; row.dataset.reversalOf = entry.reversal_of || ''; row.dataset.reversed = '0';
    const typeNames = {charge:'Charge',payment:'Payment',charge_reversal:'Charge reversal',payment_reversal:'Payment reversal',discount:'Fee discount',discount_reversal:'Discount reversal'};
    const date = new Date(String(entry.created_at).replace(' ', 'T'));
    const cells = [date.toLocaleString(), `${entry.academic_year} · ${entry.term}`, label || typeNames[entry.entry_type], `${entry.description}${reason ? ` · Reason: ${reason}` : ''}`,
      `${['charge','payment_reversal','discount_reversal'].includes(entry.entry_type) ? '+' : '−'} ${money(entry.amount)}`,
      [entry.payment_method, entry.reference].filter(Boolean).join(' ') || '—', entry.recorder, '—'];
    cells.forEach((value, i) => { const td = document.createElement('td'); td.textContent = String(value ?? '—'); if (i === 7) td.dataset.ledgerAction = ''; row.append(td); });
    if (entry.reversal_of) row.cells[7].textContent = `Reverses #${entry.reversal_of}`;
    else {
      if (entry.entry_type === 'payment') { const receipt = document.createElement('a'); receipt.className = 'button'; receipt.href = `fee_receipt.php?school_id=${encodeURIComponent(form.elements.namedItem('school_id').value)}&entry_id=${encodeURIComponent(entry.id)}`; receipt.textContent = 'Receipt'; row.cells[7].append(receipt); }
      if (page.dataset.canReverse === '1' && ['charge','payment','discount'].includes(entry.entry_type)) {
        const button = document.createElement('button'); button.type = 'button'; button.className = 'button'; button.dataset.openReversal = ''; button.dataset.id = entry.id;
        button.dataset.label = `${entry.entry_type[0].toUpperCase()}${entry.entry_type.slice(1)} · ${money(entry.amount)}`; button.textContent = 'Reverse'; row.cells[7].append(button);
      }
    }
    table.tBodies[0].prepend(row);
  }
  if (form) form.addEventListener('submit', async event => {
    event.preventDefault(); if (saving) return;
    saving = true; const button = form.querySelector('[type=submit]'); const old = button.textContent; button.disabled = true; button.textContent = 'Saving…';
    try {
      const result = await window.ShuleApi.post('accounting.php', new FormData(form), form.elements.namedItem('csrf').value);
      const d = result.data; addLedgerRow(d.entry);
      document.querySelector('[data-fee-charges]').textContent = money(d.charges);
      document.querySelector('[data-fee-payments]').textContent = money(d.payments);
      document.querySelector('[data-fee-outstanding]').textContent = money(d.outstanding);
      document.querySelectorAll('[data-pupil-balance]').forEach(el => el.textContent = money(d.balance));
      const reminder = document.querySelector('[data-queue-fee-reminder]'); if (reminder) reminder.hidden = Number(d.balance) <= 0;
      for (const name of ['description','amount','payment_method','reference']) { const input = form.elements.namedItem(name); if (input) input.value = ''; }
      notice(result.message, true);
    } catch (error) { notice(error.message); }
    finally { saving = false; button.disabled = false; button.textContent = old; }
  });
  const reminderButton = document.querySelector('[data-queue-fee-reminder]');
  if (reminderButton && form) reminderButton.addEventListener('click', async () => {
    if (saving) return;
    const body = new FormData();
    body.set('action', 'queue_fee_reminder');
    body.set('school_id', form.elements.namedItem('school_id').value);
    body.set('pupil_id', form.elements.namedItem('pupil_id').value);
    saving = true; reminderButton.disabled = true; const old = reminderButton.textContent; reminderButton.textContent = 'Queueing…';
    try {
      const result = await window.ShuleApi.post('accounting.php', body, form.elements.namedItem('csrf').value);
      notice(result.message, true);
      if (result.data.queued > 0) { reminderButton.textContent = 'Reminder queued'; }
    } catch (error) { notice(error.message); }
    finally { saving = false; if (reminderButton.textContent !== 'Reminder queued') { reminderButton.disabled = false; reminderButton.textContent = old; } }
  });
  const discountDialog=document.querySelector('#fee-discount-dialog');
  if(discountDialog&&form){document.querySelector('[data-open-discount]')?.addEventListener('click',()=>discountDialog.showModal());document.querySelectorAll('[data-close-discount]').forEach(b=>b.addEventListener('click',()=>discountDialog.close()));let applying=false;document.querySelector('#confirm-fee-discount').addEventListener('click',async e=>{if(applying||saving)return;const button=e.currentTarget,amount=document.querySelector('#fee-discount-amount').value,reason=document.querySelector('#fee-discount-reason').value.trim();if(!reason){document.querySelector('#fee-discount-reason').focus();return}const body=new FormData();body.set('school_id',form.elements.namedItem('school_id').value);body.set('pupil_id',form.elements.namedItem('pupil_id').value);body.set('academic_year',form.elements.namedItem('academic_year').value);body.set('term',form.elements.namedItem('term').value);body.set('amount',amount);body.set('reason',reason);applying=true;button.disabled=true;try{const result=await window.ShuleApi.post('api/fee_discount.php',body,form.elements.namedItem('csrf').value),d=result.data;addLedgerRow(d.entry,'Fee discount',reason);document.querySelector('[data-fee-charges]').textContent=money(d.charges);document.querySelector('[data-fee-payments]').textContent=money(d.payments);document.querySelector('[data-fee-outstanding]').textContent=money(d.outstanding);document.querySelectorAll('[data-pupil-balance]').forEach(x=>x.textContent=money(d.balance));document.querySelector('[data-queue-fee-reminder]')?.toggleAttribute('hidden',Number(d.balance)<=0);document.querySelector('#fee-discount-amount').value='';document.querySelector('#fee-discount-reason').value='';discountDialog.close();notice(result.message,true)}catch(error){notice(error.message,false,discountDialog.querySelector('.subject-dialog-body'))}finally{applying=false;button.disabled=false}})}
  if (!dialog) return;
  const close = () => { dialog.close(); document.querySelector('#fee-reversal-reason').value = ''; };
  document.querySelectorAll('[data-close-fee-reversal]').forEach(button => button.addEventListener('click', close));
  document.addEventListener('click', event => {
    const button = event.target.closest('[data-open-reversal]'); if (!button) return;
    document.querySelector('#fee-reversal-id').value = button.dataset.id;
    document.querySelector('#fee-reversal-label').textContent = button.dataset.label;
    document.querySelector('#fee-reversal-reason').value = ''; dialog.showModal();
  });
  let reversing = false;
  document.querySelector('#confirm-fee-reversal').addEventListener('click', async event => {
    const button = event.currentTarget; if (reversing) return;
    const reason = document.querySelector('#fee-reversal-reason').value.trim(); if (!reason) { document.querySelector('#fee-reversal-reason').focus(); return; }
    const sourceId = document.querySelector('#fee-reversal-id').value;
    const source = document.querySelector(`[data-ledger-row][data-entry-id="${CSS.escape(sourceId)}"]`);
    const school = document.querySelector('input[name="school_id"]')?.value, csrf = document.querySelector('input[name="csrf"]')?.value;
    if (!school || !csrf) { notice('The account context expired. Reload and try again.', false, dialog.querySelector('.subject-dialog-body')); return; }
    reversing = true; button.disabled = true; button.textContent = 'Recording…';
    try {
      const body = new FormData(); body.set('school_id', school); body.set('ledger_id', sourceId); body.set('reason', reason);
      const result = await window.ShuleApi.post('api/fee_reversal.php', body, csrf), d = result.data;
      if (source) { source.dataset.reversed = '1'; source.cells[7].querySelector('[data-open-reversal]')?.remove(); source.cells[7].append(document.createTextNode(' Reversed')); }
      addLedgerRow(d.reversal, d.reversal.entry_type === 'payment_reversal' ? 'Payment reversal' : (d.reversal.entry_type === 'discount_reversal' ? 'Discount reversal' : 'Charge reversal'), reason);
      document.querySelector('[data-fee-charges]').textContent = money(d.charges);
      document.querySelector('[data-fee-payments]').textContent = money(d.payments);
      document.querySelector('[data-fee-outstanding]').textContent = money(d.outstanding);
      document.querySelectorAll('[data-pupil-balance]').forEach(el => el.textContent = money(d.balance));
      const reminder = document.querySelector('[data-queue-fee-reminder]'); if (reminder) reminder.hidden = Number(d.balance) <= 0;
      close(); notice(result.message, true);
    } catch (error) { notice(error.message, false, dialog.querySelector('.subject-dialog-body')); }
    finally { reversing = false; button.disabled = false; button.textContent = 'Add reversal'; }
  });
});
