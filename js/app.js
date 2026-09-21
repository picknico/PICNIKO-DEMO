const tabs = [
  {key:'home', icon:'⌂', name:'Home', path:'../home/home.html'},
  {key:'discover', icon:'⌕', name:'Discover', path:'../discover/discover.html'},
  {key:'reels', icon:'▷', name:'Reels', path:'../reels/reels.html'},
  {key:'messages', icon:'◌', name:'Messages', path:'../messages/messages.html'},
  {key:'profile', icon:'●', name:'Profile', path:'../profile/profile.html'}
];

export function bottom(active){
  const tabHtml = t => `<a class="tab ${active===t.key?'active':''}" href="${t.path}"><span class="ico">${t.icon}</span><span>${t.name}</span></a>`;
  return `<nav class="bottom" aria-label="Primary navigation"><div class="bottomin">${tabs.map(tabHtml).join('')}</div></nav>`;
}

export function mountBottom(active){
  if(!document.querySelector('.bottom')) document.body.insertAdjacentHTML('beforeend',bottom(active));
}

export function createSheet(){
  if(document.querySelector('[data-create-sheet]')) return;
  const el=document.createElement('div');
  el.className='modal';
  el.dataset.createSheet='';
  el.style.display='flex';
  el.innerHTML=`<div class="sheet" role="dialog" aria-modal="true" aria-labelledby="create-title">
    <div class="row"><div class="grow"><span class="eyebrow">CREATE</span><h2 id="create-title">Create on PICNIKO</h2></div><button class="icon" data-close aria-label="Close">✕</button></div>
    <p class="muted">Share something useful, local and authentic.</p>
    <div class="creategrid">
      <button data-go="../social/social.html">✍️ <span>Post</span></button>
      <button data-go="../reels/reels.html">🎬 <span>Reel / Short</span></button>
      <button data-go="../activity/activity.html">📅 <span>Activity</span></button>
      <button data-go="../marketplace/marketplace.html">🛍️ <span>Listing</span></button>
      <button data-go="../marketplace/marketplace.html">🏷️ <span>Offer</span></button>
      <button data-go="../groups/groups.html">👥 <span>Group</span></button>
      <button data-go="../news/news.html">📰 <span>News</span></button>
      <button data-go="../social/social.html">🤝 <span>Connect</span></button>
      <button data-go="../digital-marketing/index.html">📣 <span>Campaign</span></button>
    </div>
  </div>`;
  document.body.appendChild(el);
  el.querySelector('[data-close]').onclick=()=>el.remove();
  el.addEventListener('click',e=>{
    if(e.target===el) el.remove();
    const btn=e.target.closest('[data-go]');
    if(btn) location.href=btn.dataset.go;
  });
}

document.addEventListener('click',e=>{
  if(e.target.closest('[data-create]')) createSheet();
});


export function mountAILauncher(){
  if(document.querySelector('[data-ai-launcher]')) return;
  const a=document.createElement('a');
  a.href='../ai/ai.html';
  a.className='ai-launcher';
  a.dataset.aiLauncher='';
  a.setAttribute('aria-label','PICNIKO AI');
  a.innerHTML='<span>🤖</span><small>AI</small>';
  document.body.appendChild(a);
}
document.addEventListener('DOMContentLoaded',()=>mountAILauncher());
