window.NTP = {
 money(n){return new Intl.NumberFormat("vi-VN",{style:"currency",currency:"VND",maximumFractionDigits:0}).format(Number(n||0));},
 esc(s){return String(s??"").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[m]));},
 getCart(){try{return JSON.parse(localStorage.getItem("ntpgame_cart")||"[]")}catch{return[]}},
 setCart(c){localStorage.setItem("ntpgame_cart",JSON.stringify(c));this.updateCartCount();},
 updateCartCount(){const n=this.getCart().reduce((s,x)=>s+Number(x.qty||1),0);document.querySelectorAll("#cart-count").forEach(e=>e.textContent=n);},
 addToCart(p,qty=1){let c=this.getCart();const i=c.findIndex(x=>x.id===p.id);if(i>=0)c[i].qty+=qty;else c.push({...p,qty});this.setCart(c);this.toast("Đã thêm vào giỏ hàng");},
 removeFromCart(id){this.setCart(this.getCart().filter(x=>x.id!==id));},
 clearCart(){this.setCart([]);},
 toast(msg){let x=document.querySelector(".toast");if(!x){x=document.createElement("div");x.className="toast";document.body.appendChild(x)}x.textContent=msg;x.classList.add("show");setTimeout(()=>x.classList.remove("show"),2200);},
 async products(){if(window.ntpSupabase){const {data,error}=await ntpSupabase.from("products").select("*").eq("is_active",true).order("created_at",{ascending:false});if(!error&&data?.length)return data;}return window.DEMO_PRODUCTS;},
 async services(){if(window.ntpSupabase){const {data,error}=await ntpSupabase.from("products").select("*").eq("is_active",true).in("category",["service","digital"]).order("created_at",{ascending:false});if(!error&&data?.length)return data;}return window.DEMO_SERVICES;},
 async user(){if(!window.ntpSupabase)return null;const {data}=await ntpSupabase.auth.getUser();return data?.user||null;},
 async profile(){const u=await this.user();if(!u)return null;const {data}=await ntpSupabase.from("profiles").select("*").eq("id",u.id).maybeSingle();return data;},
 requireUser(){if(!window.ntpSupabase){location.href="login.html?demo=1";return false;}return true;}
};
document.addEventListener("DOMContentLoaded",()=>{
 NTP.updateCartCount();
 const toggle=document.getElementById("mobile-toggle"),nav=document.getElementById("main-nav"); if(toggle&&nav)toggle.onclick=()=>nav.classList.toggle("open");
 if(window.ntpSupabase){ntpSupabase.auth.getUser().then(async({data})=>{const a=document.getElementById("account-link");if(a&&data.user){a.textContent="Tài khoản";a.href="orders.html";}})}
});