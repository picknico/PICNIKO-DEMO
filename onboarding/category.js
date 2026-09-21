const cards=[...document.querySelectorAll('.category')];
const continueBtn=document.getElementById('continueBtn');
let selected=null;
const labels={student:'Student',teacher:'Teacher',civic:'Civic Member','real-estate':'Real Estate Agent',developer:'Developer','hotel-restaurant':'Hotel / Restaurant','picnic-point':'Picnic Point',business:'Businessman',creator:'Creator',professional:'Professional',traveller:'Traveller',other:'Other'};
function selectCard(card){cards.forEach(c=>c.classList.remove('selected'));card.classList.add('selected');selected=card.dataset.key;continueBtn.disabled=false;}
cards.forEach(card=>card.addEventListener('click',()=>selectCard(card)));
continueBtn.addEventListener('click',()=>{if(!selected)return;localStorage.setItem('picniko_category',selected);localStorage.setItem('picniko_category_label',labels[selected]);localStorage.setItem('picniko_onboarding_complete','1');location.href='../modules/home/home.html';});
document.getElementById('skipBtn').addEventListener('click',()=>{localStorage.setItem('picniko_category','other');localStorage.setItem('picniko_category_label','Other');localStorage.setItem('picniko_onboarding_complete','1');location.href='../modules/home/home.html';});
document.getElementById('backBtn').addEventListener('click',()=>location.href='../auth/login.html');
