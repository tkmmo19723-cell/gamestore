document.addEventListener("DOMContentLoaded",async()=>{
const data=await NTP.services(), g=document.getElementById("game-services"), d=document.getElementById("digital-services");
const make=p=>`<article class="service-card service-large"><div class="service-icon">${p.image||"⚡"}</div><div class="service-content"><div class="product-meta"><span>${NTP.esc(p.game)}</span><span>Đặt theo gói</span></div><h3>${NTP.esc(p.name)}</h3><p>${NTP.esc(p.description||"")}</p><div class="service-bottom"><strong>${NTP.money(p.price)} <small>/ ${p.unit||"gói"}</small></strong><button class="btn btn-primary add-service" data-id="${NTP.esc(p.id)}">Thêm dịch vụ</button></div></div></article>`;
g.innerHTML=data.filter(x=>x.category==="service").map(make).join("");d.innerHTML=data.filter(x=>x.category==="digital").map(make).join("");
document.addEventListener("click",e=>{const b=e.target.closest(".add-service");if(b){const p=data.find(x=>x.id===b.dataset.id);if(p)NTP.addToCart(p)}})
});