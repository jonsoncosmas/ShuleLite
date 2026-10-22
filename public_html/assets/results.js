document.addEventListener('DOMContentLoaded',()=>{
  const status=document.querySelector('#results-async-status');if(!status)return;
  const show=(message,error=false)=>{status.hidden=false;status.className=error?'notice error':'notice success';status.textContent=message;status.scrollIntoView({block:'nearest',behavior:'smooth'})};
  document.querySelectorAll('.results-edit-form').forEach(form=>form.addEventListener('submit',async event=>{
    event.preventDefault();if(form.dataset.saving==='1')return;const button=event.submitter||form.querySelector('[type=submit]');form.dataset.saving='1';if(button){button.disabled=true;button.dataset.originalText=button.textContent;button.textContent='Saving…'}
    try{
      const response=await fetch(form.action||location.href,{method:'POST',body:new FormData(form),credentials:'same-origin',headers:{Accept:'application/json'}});const type=response.headers.get('content-type')||'';if(!type.includes('application/json'))throw new Error(response.redirected?'Your session expired. Sign in again.':'The server returned an unexpected response. Refresh and try again.');const result=await response.json();if(!response.ok||result.ok!==true)throw new Error(result.message||'Scores could not be saved.');
      const byCell=new Map((result.data.created||[]).map(row=>[`${row.pupil_id}:${row.subject_id}`,row]));for(const input of form.querySelectorAll('input[name^="new_score["]')){const match=input.name.match(/^new_score\[(\d+)\]\[(\d+)\]$/);if(!match||input.value==='')continue;const row=byCell.get(`${match[1]}:${match[2]}`);if(!row)continue;input.name=`score[${row.result_id}]`;input.max=String(row.max_score);input.required=true;input.removeAttribute('placeholder');const label=input.closest('label');const caption=label?.querySelector('span');if(caption)caption.textContent=form.querySelector('[name="assessment"]')?.value||'Score'}
      show(result.message);if(button){button.textContent='Saved';setTimeout(()=>{if(button.isConnected)button.textContent=button.dataset.originalText||'Save scores'},1200)}
    }catch(error){show(error.message||'Connection interrupted. Check your network and try again.',true);if(button)button.textContent=button.dataset.originalText||'Save scores'}finally{form.dataset.saving='0';if(button)button.disabled=false}
  }));
});
