const KEY="ntpgame_cart";let cart=JSON.parse(localStorage.getItem(KEY)||"[]");
function save(){localStorage.setItem(KEY,JSON.stringify(cart));updateCart()}
function updateCart(){document.querySelectorAll("#cartCount").forEach(e=>e.textContent=cart.reduce((a,x)=>a+x.qty,0))}
function addCart(name,price){let x=cart.find(i=>i.name===name);x?x.qty++:cart.push({name,price,qty:1});save();toast("Đã thêm vào giỏ hàng 🛒")}
function toast(t){let e=document.createElement("div");e.className="toast";e.textContent=t;document.body.appendChild(e);setTimeout(()=>e.classList.add("show"),20);setTimeout(()=>{e.classList.remove("show");setTimeout(()=>e.remove(),250)},1800)}
updateCart();
document.querySelectorAll(".game-tabs button").forEach(b=>b.onclick=()=>{document.querySelectorAll(".game-tabs button").forEach(x=>x.classList.remove("active"));b.classList.add("active");let g=b.dataset.game;document.querySelectorAll(".product").forEach(p=>p.style.display=g==="all"||p.dataset.game===g?"":"none")});
