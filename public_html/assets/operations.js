document.addEventListener('DOMContentLoaded', () => {
  const busy = new WeakSet();
  document.addEventListener('change', event => {
    const movement = event.target.closest('select[name="movement_type"]'); if (!movement) return;
    const reason = movement.form?.elements.namedItem('note'); if (reason) reason.required = movement.value === 'adjusted';
    const supplier = movement.form?.querySelector('[data-supplier-select]'); if (supplier) { supplier.hidden = movement.value !== 'received'; supplier.disabled = movement.value !== 'received'; if (supplier.disabled) supplier.value = ''; }
  });
  function report(target, message, success = false) {
    document.querySelector('.page-content .notice[data-async-result]')?.remove();
    const notice = document.createElement('div'); notice.className = `notice ${success ? 'success' : 'error'}`;
    notice.dataset.asyncResult = '1'; notice.setAttribute('role', success ? 'status' : 'alert'); notice.textContent = message;
    target.prepend(notice);
  }
  function refreshQuery(form) {
    const params = new URLSearchParams();
    const action = form.elements.namedItem('action')?.value || '';
    const tab = action === 'save_contract' ? 'contracts' : ['save_leave_request','review_leave_request','cancel_leave_request'].includes(action) ? 'leave' : ['save_item','move_stock','request_stock','review_stock_request','issue_stock_request'].includes(action) ? 'stock' : 'attendance';
    params.set('tab', tab);
    const school = form.elements.namedItem('school_id')?.value; if (school) params.set('school_id', school);
    if (action === 'save_attendance') {
      const date = form.elements.namedItem('attendance_date')?.value, klass = form.elements.namedItem('class_level')?.value;
      if (date) params.set('date', date); if (klass) params.set('class', klass);
    }
    if (action === 'save_contract') {
      const id = form.elements.namedItem('contract_id')?.value; if (id && Number(id) > 0) params.set('edit', id);
    }
    return params;
  }
  document.addEventListener('submit', async event => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement) || form.method.toLowerCase() !== 'post') return;
    event.preventDefault(); if (busy.has(form)) return; busy.add(form);
    const submitter = event.submitter, oldText = submitter?.textContent;
    if (submitter) { submitter.disabled = true; submitter.textContent = 'Saving…'; }
    const data = new FormData(form);
    if (submitter?.name) data.set(submitter.name, submitter.value);
    try {
      const result = await window.ShuleApi.post('operations.php', data, form.elements.namedItem('csrf')?.value || '');
      const params = refreshQuery(form), response = await fetch(`operations.php?${params.toString()}`, {credentials:'same-origin',headers:{Accept:'text/html'}});
      if (!response.ok) throw new Error('The change was saved, but the updated view could not be loaded. Refresh the page.');
      const html = await response.text(), next = new DOMParser().parseFromString(html, 'text/html').querySelector('.page-content');
      const current = document.querySelector('.page-content');
      if (!next || !current) throw new Error('The change was saved, but the updated view could not be loaded. Refresh the page.');
      current.innerHTML = next.innerHTML;
      const success = document.createElement('div'); success.className = 'notice success'; success.setAttribute('role','status'); success.dataset.asyncResult = '1'; success.textContent = result.message;
      current.prepend(success);
      const url = new URL(location.href); for (const [key,value] of params) url.searchParams.set(key,value); history.replaceState(null,'',url);
    } catch (error) {
      report(document.querySelector('.page-content') || document.body, error.message);
    } finally {
      busy.delete(form); if (submitter) { submitter.disabled = false; submitter.textContent = oldText; }
    }
  });
  const attendanceRoot=document.querySelector('[data-attendance-report]');
  if(attendanceRoot){
    const form=attendanceRoot.querySelector('[data-attendance-report-filter]'),output=attendanceRoot.querySelector('[data-attendance-report-output]');let loading=false;
    const makeTable=(headers,rows,empty)=>{if(!rows.length){const p=document.createElement('p');p.className='muted';p.textContent=empty;return p}const wrap=document.createElement('div'),table=document.createElement('table'),head=document.createElement('thead'),hr=document.createElement('tr'),body=document.createElement('tbody');wrap.className='table-wrap';headers.forEach(v=>{const th=document.createElement('th');th.textContent=v;hr.append(th)});head.append(hr);rows.forEach(values=>{const tr=document.createElement('tr');values.forEach(v=>{const td=document.createElement('td');td.textContent=String(v??'');tr.append(td)});body.append(tr)});table.append(head,body);wrap.append(table);return wrap};
    const load=async()=>{if(loading)return;loading=true;output.replaceChildren(Object.assign(document.createElement('p'),{textContent:'Loading attendance summary…',className:'muted'}));try{const params=new URLSearchParams(new FormData(form)),response=await fetch(`${attendanceRoot.dataset.api}?${params}`,{credentials:'same-origin',headers:{Accept:'application/json'}}),result=await response.json();if(!response.ok||!result.ok)throw new Error(result.message||'Attendance report failed to load.');const data=result.data;const byStatus={};for(const row of data.by_class){byStatus[row.attendance_status]=(byStatus[row.attendance_status]||0)+Number(row.total)}const summary=document.createElement('p');summary.className='muted';summary.textContent=Object.entries(byStatus).map(([k,v])=>`${k}: ${v}`).join(' · ')||'No attendance marks in this range.';output.replaceChildren(summary,makeTable(['Class','Present','Absent','Late','Excused','Total'],(()=>{const groups={};for(const r of data.by_class){groups[r.class_level]??={present:0,absent:0,late:0,excused:0};groups[r.class_level][r.attendance_status]=Number(r.total)}return Object.entries(groups).map(([name,v])=>[name,v.present,v.absent,v.late,v.excused,v.present+v.absent+v.late+v.excused])})(),'No class attendance marks for this period.'),makeTable(['Date','Present','Absent','Late','Excused','Pupils marked'],data.by_date.map(r=>[r.attendance_date,r.present,r.absent,r.late,r.excused,r.marked]),'No daily attendance marks for this period.'));}catch(error){const p=document.createElement('p');p.className='notice error';p.setAttribute('role','alert');p.textContent=error.message;output.replaceChildren(p)}finally{loading=false}};
    form.addEventListener('submit',event=>{event.preventDefault();load()});load();
  }

});
