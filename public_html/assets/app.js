document.addEventListener('DOMContentLoaded',()=>{
  document.addEventListener('click',event=>{
    const button=event.target.closest('[data-future-action]');
    if(!button)return;
    let status=document.querySelector('#future-action-status');
    if(!status){status=document.createElement('p');status.id='future-action-status';status.className='notice';status.setAttribute('role','status');status.setAttribute('aria-live','polite');document.querySelector('.page-content')?.prepend(status)}
    status.textContent=button.dataset.futureAction+' action will be available in a later update.'
  });
  const toggle=document.querySelector('[data-menu]');
  const sidebar=document.querySelector('.sidebar');
  const shell=document.querySelector('.app-shell');
  const mobile=()=>window.matchMedia('(max-width: 768px)').matches;
  const saved=localStorage.getItem('shule-sidebar-collapsed')==='true';
  if(sidebar&&shell&&!mobile()&&saved)shell.classList.add('sidebar-collapsed');
  const syncToggle=()=>{
    if(!toggle||!sidebar)return;
    const expanded=mobile()?sidebar.classList.contains('open'):!shell.classList.contains('sidebar-collapsed');
    const compact=!mobile()&&shell.classList.contains('sidebar-collapsed');
    sidebar.querySelectorAll('.nav-item').forEach(item=>{
      if(compact&&!item.hasAttribute('title')){item.title=item.textContent.trim();item.dataset.collapsedTitle='true'}
      else if(!compact&&item.dataset.collapsedTitle){item.removeAttribute('title');delete item.dataset.collapsedTitle}
    });
    toggle.setAttribute('aria-expanded',String(expanded));
    toggle.setAttribute('aria-label',expanded?'Collapse navigation':'Expand navigation');
    toggle.title=expanded?'Collapse navigation':'Expand navigation';
  };
  if(toggle&&sidebar&&shell){
    syncToggle();
    toggle.addEventListener('click',()=>{
      if(mobile())sidebar.classList.toggle('open');
      else {shell.classList.toggle('sidebar-collapsed');localStorage.setItem('shule-sidebar-collapsed',String(shell.classList.contains('sidebar-collapsed')))}
      syncToggle();
    });
    window.addEventListener('resize',()=>{if(mobile())shell.classList.remove('sidebar-collapsed');else sidebar.classList.remove('open');syncToggle()});
  }
  const passwordToggle=document.querySelector('.password-toggle');
  const password=document.querySelector('#password');
  if(passwordToggle&&password)passwordToggle.addEventListener('click',()=>{const show=password.type==='password';password.type=show?'text':'password';passwordToggle.textContent=show?'Hide':'Show';passwordToggle.setAttribute('aria-pressed',String(show));passwordToggle.setAttribute('aria-label',show?'Hide password':'Show password')});
  document.addEventListener('keydown',event=>{if(event.key==='Escape'&&sidebar?.classList.contains('open')){sidebar.classList.remove('open');syncToggle()}})
});
