import { useState, useEffect, useCallback } from "react";

// ─── TOKENS ───
const T = {
  dark:"#0B3B2D", darkMid:"#145A42", green:"#1B7A5A", greenLight:"#28A87A",
  lime:"#A8E06C", limeLight:"#C5F08A", gold:"#D4A24E", saffron:"#E8813A",
  red:"#E53935", white:"#FFFFFF", cream:"#F8FAF6", bg:"#F2F5EF",
  card:"#FFFFFF", text:"#0B2B20", textMid:"#3D6050", textLight:"#7FA090",
  border:"#E4ECE6", borderLight:"#EFF3ED",
  sh:"0 2px 12px rgba(11,59,45,0.06)", shM:"0 6px 24px rgba(11,59,45,0.08)", shL:"0 12px 40px rgba(11,59,45,0.12)",
};
const cats = [
  {name:"Veggies",icon:"🥬",bg:"#E8F5E9",ac:"#2E7D32"},
  {name:"Spices",icon:"🌶️",bg:"#FFF3E0",ac:"#E65100"},
  {name:"Rice",icon:"🍚",bg:"#F3E5F5",ac:"#6A1B9A"},
  {name:"Fruits",icon:"🍎",bg:"#FFEBEE",ac:"#C62828"},
  {name:"Frozen",icon:"🧊",bg:"#E3F2FD",ac:"#1565C0"},
  {name:"Drinks",icon:"🥤",bg:"#E0F7FA",ac:"#00838F"},
  {name:"Meats",icon:"🍗",bg:"#FBE9E7",ac:"#BF360C"},
  {name:"Breads",icon:"🫓",bg:"#FFF8E1",ac:"#F9A825"},
];
const prods = [
  {id:1,name:"Basmati Rice",sub:"Premium · 5kg",p:8,d:99,old:"10.99",img:"🍚",badge:"Best Seller",bc:T.dark},
  {id:2,name:"Fresh Coriander",sub:"Local · Bunch",p:0,d:79,img:"🌿"},
  {id:3,name:"Turmeric Powder",sub:"Organic · 200g",p:2,d:49,old:"3.29",img:"✨",badge:"20% Off",bc:T.saffron},
  {id:4,name:"Coconut Milk",sub:"Premium · 400ml",p:1,d:29,img:"🥥",badge:"New",bc:T.greenLight},
  {id:5,name:"Paratha",sub:"Frozen · 5 Pack",p:2,d:99,img:"🫓"},
  {id:6,name:"Mango Lassi",sub:"Chilled · 250ml",p:1,d:49,img:"🥭",badge:"Popular",bc:T.gold},
  {id:7,name:"Garam Masala",sub:"Blend · 100g",p:1,d:99,img:"🫙"},
  {id:8,name:"Chicken Biryani",sub:"Ready · 350g",p:4,d:99,img:"🍗",badge:"Hot",bc:T.red},
];
const cartData = [{...prods[0],qty:2},{...prods[2],qty:1},{...prods[3],qty:3},{...prods[5],qty:2}];
const orderSteps = [
  {l:"Order Placed",t:"2:15 PM",icon:"📋"},{l:"Confirmed",t:"2:16 PM",icon:"✅"},
  {l:"Preparing",t:"2:22 PM",icon:"👨‍🍳"},{l:"Out for Delivery",t:"2:48 PM",icon:"🛵"},
  {l:"Delivered",t:"~3:10 PM",icon:"🏠"},
];
const subCats = ["All","Ground","Whole","Blends","Pastes","Seeds","Herbs"];

// ─── HELPERS ───
function An({children,delay=0,type="up",style={}}){
  const [v,setV]=useState(false);
  useEffect(()=>{const t=setTimeout(()=>setV(true),delay);return()=>clearTimeout(t)},[delay]);
  const tr={up:"translateY(20px)",down:"translateY(-16px)",scale:"scale(0.9)",left:"translateX(-20px)",right:"translateX(20px)"};
  return <div style={{opacity:v?1:0,transform:v?"none":tr[type],transition:`all 0.55s cubic-bezier(0.16,1,0.3,1)`,...style}}>{children}</div>;
}
function Price({p,d,size=22,color=T.text}){
  return <span style={{fontSize:size,fontWeight:800,color,fontFamily:"'DM Sans',sans-serif"}}>£{p}.<sup style={{fontSize:size*0.55,fontWeight:700,verticalAlign:"super",position:"relative",top:-2}}>{String(d).padStart(2,"0")}</sup></span>;
}
function Qty({qty,onM,onP,s=32}){
  return <div style={{display:"flex",alignItems:"center",gap:4}}>
    <div onClick={onM} style={{width:s,height:s,borderRadius:s/2,border:`1.5px solid ${T.border}`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:s*.5,color:T.textLight,cursor:"pointer",background:T.card}}>−</div>
    <span style={{width:s*.7,textAlign:"center",fontSize:s*.45,fontWeight:800,color:T.text}}>{qty}</span>
    <div onClick={onP} style={{width:s,height:s,borderRadius:s/2,border:`1.5px solid ${T.greenLight}`,background:`${T.greenLight}15`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:s*.5,color:T.greenLight,cursor:"pointer"}}>+</div>
  </div>;
}
function LimeBtn({children,onClick,style={},processing}){
  const [pr,setPr]=useState(false);
  return <button onClick={onClick} onMouseDown={()=>setPr(true)} onMouseUp={()=>setPr(false)} onMouseLeave={()=>setPr(false)} style={{width:"100%",padding:"15px 24px",borderRadius:16,border:"none",background:`linear-gradient(135deg,${T.lime},${T.limeLight})`,color:T.dark,fontSize:15,fontWeight:800,cursor:"pointer",fontFamily:"'DM Sans',sans-serif",transition:"all 0.25s cubic-bezier(0.34,1.56,0.64,1)",transform:pr?"scale(0.97)":"scale(1)",boxShadow:`0 6px 20px ${T.lime}50`,...style}}>{processing?<span style={{display:"flex",alignItems:"center",justifyContent:"center",gap:8}}><span style={{width:16,height:16,border:`2px solid ${T.dark}30`,borderTopColor:T.dark,borderRadius:"50%",animation:"spin 0.7s linear infinite",display:"inline-block"}}/>Processing...</span>:children}</button>;
}
function CurvedHeader({children,onNav,noSearch}){
  return <div style={{position:"relative",background:`linear-gradient(160deg,${T.dark} 0%,${T.darkMid} 50%,${T.green} 100%)`,paddingTop:56,paddingBottom:noSearch?50:60,overflow:"visible"}}>
    {[...Array(5)].map((_,i)=><div key={i} style={{position:"absolute",width:50+i*30,height:50+i*30,borderRadius:"50%",border:"1px solid rgba(255,255,255,0.04)",top:-10+i*8,right:-15+i*18}}/>)}
    <div style={{position:"relative",zIndex:2,padding:"0 22px"}}>{children}</div>
    <div style={{position:"absolute",bottom:-1,left:0,right:0}}><svg viewBox="0 0 393 36" style={{width:"100%",display:"block"}}><path d="M0 0 C80 36, 313 36, 393 0 L393 36 L0 36 Z" fill={T.cream}/></svg></div>
  </div>;
}
function BackBtn({onClick}){return <div onClick={onClick} style={{width:36,height:36,borderRadius:12,background:"rgba(255,255,255,0.1)",border:"1px solid rgba(255,255,255,0.08)",display:"flex",alignItems:"center",justifyContent:"center",cursor:"pointer",fontSize:14,color:"#fff"}}>←</div>}

// ─── PHONE ───
function Phone({children,activeTab,onNav,cartCount=4}){
  const tabs=[{id:"home",i:"🏠",l:"Home"},{id:"explore",i:"🔍",l:"Explore"},{id:"cart",i:"🛒",l:"Cart"},{id:"orders",i:"📦",l:"Orders"},{id:"profile",i:"👤",l:"Account"}];
  return <div style={{width:393,height:852,background:T.cream,borderRadius:50,border:`4px solid ${T.dark}`,overflow:"hidden",position:"relative",boxShadow:`0 30px 80px rgba(11,59,45,0.2)`,fontFamily:"'DM Sans',sans-serif"}}>
    <div style={{position:"absolute",top:10,left:"50%",transform:"translateX(-50%)",width:126,height:34,borderRadius:20,background:T.dark,zIndex:50}}/>
    <div style={{height:708,overflow:"auto"}}>{children}</div>
    <div style={{position:"absolute",bottom:0,left:0,right:0,height:90,background:"rgba(255,255,255,0.96)",backdropFilter:"blur(20px)",borderTop:`1px solid ${T.border}`,display:"flex",alignItems:"flex-start",paddingTop:8,zIndex:40}}>
      {tabs.map(t=>{const a=activeTab===t.id;return <div key={t.id} onClick={()=>onNav?.(t.id)} style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",gap:2,cursor:"pointer",position:"relative"}}>
        {a&&<div style={{position:"absolute",top:-8,width:24,height:3,borderRadius:2,background:T.green}}/>}
        <div style={{fontSize:22,filter:a?"none":"grayscale(0.8) opacity(0.4)",transition:"all 0.3s"}}>{t.i}</div>
        <span style={{fontSize:10,fontWeight:a?700:500,color:a?T.green:T.textLight}}>{t.l}</span>
        {t.id==="cart"&&cartCount>0&&<div style={{position:"absolute",top:-2,right:"calc(50% - 20px)",minWidth:18,height:18,borderRadius:9,background:`linear-gradient(135deg,${T.lime},${T.limeLight})`,color:T.dark,fontSize:10,fontWeight:800,display:"flex",alignItems:"center",justifyContent:"center",padding:"0 4px"}}>{cartCount}</div>}
      </div>})}
    </div>
    <style>{`
      @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,600;0,700;0,800;1,400&display=swap');
      @keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-5px)}}
      @keyframes pulse{0%,100%{transform:scale(1)}50%{transform:scale(1.06)}}
      @keyframes spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
      @keyframes gradMove{0%{background-position:0% 50%}50%{background-position:100% 50%}100%{background-position:0% 50%}}
      *{scrollbar-width:none}*::-webkit-scrollbar{display:none}
    `}</style>
  </div>;
}

// ═════════════ SPLASH ═════════════
function Splash({onNav}){
  const [phase,setPhase]=useState(0);
  useEffect(()=>{const t=[setTimeout(()=>setPhase(1),300),setTimeout(()=>setPhase(2),900),setTimeout(()=>setPhase(3),1500),setTimeout(()=>onNav?.("home"),2800)];return()=>t.forEach(clearTimeout)},[]);
  return <div style={{width:393,height:852,borderRadius:50,border:`4px solid ${T.dark}`,overflow:"hidden",boxShadow:`0 30px 80px rgba(11,59,45,0.2)`,position:"relative",background:`linear-gradient(160deg,#041F15 0%,${T.dark} 30%,${T.green} 70%,${T.greenLight} 100%)`,backgroundSize:"200% 200%",animation:"gradMove 5s ease infinite",display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",fontFamily:"'DM Sans',sans-serif"}}>
    {["🌶️","🍚","🥥","🫙","🍛","🌿","🥭","🫓"].map((e,i)=><div key={i} style={{position:"absolute",top:`${12+(i*11)%65}%`,left:`${8+(i*15)%80}%`,fontSize:26,opacity:phase>=2?0.15:0,transition:`all 0.8s ease ${i*0.08}s`,animation:phase>=2?`float ${2.5+i*0.3}s ease-in-out infinite ${i*0.15}s`:"none"}}>{e}</div>)}
    <div style={{width:110,height:110,borderRadius:30,background:"rgba(255,255,255,0.12)",backdropFilter:"blur(16px)",border:"2px solid rgba(255,255,255,0.2)",display:"flex",alignItems:"center",justifyContent:"center",fontSize:54,marginBottom:24,transition:"all 0.8s cubic-bezier(0.34,1.56,0.64,1)",transform:phase>=1?"scale(1) rotate(0deg)":"scale(0) rotate(-180deg)",opacity:phase>=1?1:0,boxShadow:"0 12px 40px rgba(0,0,0,0.2)"}}>🏪</div>
    <div style={{transition:"all 0.6s ease 0.3s",opacity:phase>=2?1:0,transform:phase>=2?"translateY(0)":"translateY(16px)"}}>
      <div style={{fontSize:36,fontWeight:800,color:"#fff",textAlign:"center",letterSpacing:1.5,fontFamily:"'Playfair Display',serif"}}>AMMA</div>
      <div style={{fontSize:15,fontWeight:500,color:"rgba(255,255,255,0.8)",textAlign:"center",letterSpacing:5,marginTop:2}}>FOOD CITY</div>
    </div>
    <div style={{marginTop:14,fontSize:13,color:"rgba(168,224,108,0.8)",transition:"all 0.6s ease 0.6s",opacity:phase>=2?1:0,letterSpacing:0.5}}>Fresh Asian Grocery, Delivered</div>
    <div style={{marginTop:40,display:"flex",gap:8,transition:"all 0.5s ease 0.8s",opacity:phase>=3?1:0}}>
      {[0,1,2].map(i=><div key={i} style={{width:8,height:8,borderRadius:4,background:i===1?T.lime:"rgba(255,255,255,0.4)",animation:`pulse 1.2s ease-in-out ${i*0.2}s infinite`}}/>)}
    </div>
  </div>;
}

// ═════════════ HOME ═════════════
function Home({onNav}){
  const [addedId,setAddedId]=useState(null);
  const add=(id,e)=>{e?.stopPropagation();setAddedId(id);setTimeout(()=>setAddedId(null),900)};
  return <Phone activeTab="home" onNav={onNav}>
    <CurvedHeader>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:14}}>
        <div><div style={{fontSize:12,color:"rgba(168,224,108,0.7)",fontWeight:500}}>📍 Delivering to Glasgow</div><div style={{fontSize:22,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>Amma Food City</div></div>
        <div style={{display:"flex",gap:8}}>
          <div style={{width:38,height:38,borderRadius:14,background:"rgba(255,255,255,0.1)",border:"1px solid rgba(255,255,255,0.08)",display:"flex",alignItems:"center",justifyContent:"center",fontSize:16,cursor:"pointer"}}>🔔</div>
          <div onClick={()=>onNav?.("profile")} style={{width:38,height:38,borderRadius:14,background:T.lime,display:"flex",alignItems:"center",justifyContent:"center",fontSize:14,fontWeight:800,color:T.dark,cursor:"pointer"}}>V</div>
        </div>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:10,padding:"12px 16px",borderRadius:14,background:"rgba(255,255,255,0.1)",backdropFilter:"blur(8px)",border:"1px solid rgba(255,255,255,0.08)"}}>
        <span style={{fontSize:15,opacity:0.6}}>🔍</span><span style={{fontSize:14,color:"rgba(255,255,255,0.5)"}}>Search for "Grocery"</span>
      </div>
    </CurvedHeader>

    {/* Categories on curve */}
    <div style={{marginTop:-28,position:"relative",zIndex:10,padding:"0 12px"}}>
      <div style={{display:"flex",justifyContent:"center",gap:6,flexWrap:"wrap"}}>
        {cats.map((c,i)=><An key={i} delay={80+i*35} type="scale" style={{textAlign:"center",width:58}}>
          <div onClick={()=>onNav?.("explore")} style={{width:50,height:50,borderRadius:25,margin:"0 auto 3px",background:c.bg,border:`2.5px solid ${T.card}`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:22,cursor:"pointer",boxShadow:T.sh,transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)"}} onMouseEnter={e=>e.currentTarget.style.transform="scale(1.12)"} onMouseLeave={e=>e.currentTarget.style.transform="scale(1)"}>{c.icon}</div>
          <div style={{fontSize:9,fontWeight:600,color:T.textMid}}>{c.name}</div>
        </An>)}
      </div>
    </div>

    {/* Promo */}
    <An delay={380} type="up"><div style={{margin:"14px 16px 0",padding:"12px 16px",borderRadius:14,background:`linear-gradient(135deg,${T.dark},${T.darkMid})`,display:"flex",alignItems:"center",gap:12,position:"relative",overflow:"hidden"}}>
      {[...Array(3)].map((_,i)=><div key={i} style={{position:"absolute",width:35+i*15,height:35+i*15,borderRadius:"50%",border:"1px solid rgba(168,224,108,0.06)",right:-5+i*18,top:-5+i*6}}/>)}
      <span style={{fontSize:28}}>🎁</span>
      <div style={{flex:1}}><div style={{fontSize:13,fontWeight:700,color:"#fff"}}>10% off first order</div><div style={{fontSize:11,color:"rgba(255,255,255,0.5)"}}>Code <span style={{color:T.lime,fontWeight:700}}>AMMA10</span></div></div>
      <div style={{padding:"7px 14px",borderRadius:10,background:T.lime,color:T.dark,fontSize:11,fontWeight:700,cursor:"pointer"}}>Apply</div>
    </div></An>

    {/* Delivery toggle */}
    <An delay={460} type="up"><div style={{margin:"14px 16px 0",display:"flex",gap:8}}>
      {[["🛵","Delivery","15 min"],["🏪","Pickup","10 min"]].map(([ic,lb,sb],i)=><div key={i} style={{flex:1,padding:"12px 14px",borderRadius:14,background:i===0?`${T.greenLight}10`:T.card,border:`1.5px solid ${i===0?T.greenLight+"35":T.border}`,display:"flex",alignItems:"center",gap:8,cursor:"pointer"}}>
        <div style={{width:36,height:36,borderRadius:10,background:i===0?`${T.greenLight}18`:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:18}}>{ic}</div>
        <div><div style={{fontSize:13,fontWeight:700,color:i===0?T.green:T.text}}>{lb}</div><div style={{fontSize:10,color:T.textLight}}>{sb}</div></div>
      </div>)}
    </div></An>

    {/* You might need — horizontal */}
    <An delay={530} type="up"><div style={{padding:"16px 20px 0"}}><div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline"}}><span style={{fontSize:18,fontWeight:800,color:T.text,fontFamily:"'Playfair Display',serif"}}>You might need</span><span style={{fontSize:12,color:T.greenLight,fontWeight:600,cursor:"pointer"}}>See more</span></div></div></An>
    <div style={{display:"flex",gap:10,padding:"12px 16px",overflowX:"auto"}}>
      {prods.slice(0,4).map((p,i)=><An key={p.id} delay={570+i*50} type="up" style={{flexShrink:0}}>
        <div onClick={()=>onNav?.("product")} style={{width:138,background:T.card,borderRadius:16,boxShadow:T.sh,cursor:"pointer",overflow:"hidden",border:`1px solid ${T.borderLight}`,transition:"all 0.3s"}} onMouseEnter={e=>{e.currentTarget.style.transform="translateY(-2px)";e.currentTarget.style.boxShadow=T.shM}} onMouseLeave={e=>{e.currentTarget.style.transform="none";e.currentTarget.style.boxShadow=T.sh}}>
          <div style={{height:100,background:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:46,position:"relative"}}>
            <div style={{animation:`float ${2.5+i*0.3}s ease-in-out infinite`}}>{p.img}</div>
            {p.badge&&<span style={{position:"absolute",top:7,left:7,background:p.bc||T.dark,color:"#fff",fontSize:8,fontWeight:700,padding:"3px 7px",borderRadius:5}}>{p.badge}</span>}
          </div>
          <div style={{padding:"8px 10px 10px",textAlign:"center"}}>
            <div style={{fontSize:12,fontWeight:700,color:T.text}}>{p.name}</div>
            <div style={{fontSize:10,color:T.textLight,marginBottom:6}}>{p.sub}</div>
            <Price p={p.p} d={p.d} size={18}/>
            <div onClick={e=>add(p.id,e)} style={{margin:"8px auto 0",padding:"7px",borderRadius:10,border:addedId===p.id?"none":`1.5px solid ${T.border}`,background:addedId===p.id?`linear-gradient(135deg,${T.lime},${T.limeLight})`:"transparent",color:addedId===p.id?T.dark:T.textLight,fontSize:16,cursor:"pointer",transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)",transform:addedId===p.id?"scale(1.05)":"scale(1)"}}>{addedId===p.id?"✓":"+"}</div>
          </div>
        </div>
      </An>)}
    </div>

    {/* Best selling — grid */}
    <An delay={780} type="up"><div style={{padding:"14px 20px 6px"}}><span style={{fontSize:18,fontWeight:800,color:T.text,fontFamily:"'Playfair Display',serif"}}>Best selling</span></div></An>
    <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10,padding:"0 16px 100px"}}>
      {prods.map((p,i)=><An key={p.id} delay={820+i*40} type="up">
        <div onClick={()=>onNav?.("product")} style={{background:T.card,borderRadius:14,overflow:"hidden",border:`1px solid ${T.borderLight}`,boxShadow:T.sh,cursor:"pointer",transition:"all 0.3s"}} onMouseEnter={e=>{e.currentTarget.style.transform="translateY(-2px)"}} onMouseLeave={e=>{e.currentTarget.style.transform="none"}}>
          <div style={{height:85,background:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:38,position:"relative"}}>{p.img}{p.badge&&<span style={{position:"absolute",top:6,left:6,background:p.bc||T.dark,color:"#fff",fontSize:7,fontWeight:700,padding:"2px 6px",borderRadius:4}}>{p.badge}</span>}</div>
          <div style={{padding:"7px 9px 9px"}}><div style={{fontSize:12,fontWeight:700,color:T.text}}>{p.name}</div><div style={{fontSize:9,color:T.textLight,marginBottom:5}}>{p.sub}</div>
            <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}><Price p={p.p} d={p.d} size={15}/>
              <div onClick={e=>add(p.id,e)} style={{width:26,height:26,borderRadius:13,border:addedId===p.id?"none":`1.5px solid ${T.border}`,background:addedId===p.id?T.lime:"transparent",display:"flex",alignItems:"center",justifyContent:"center",color:addedId===p.id?T.dark:T.textLight,fontSize:14,cursor:"pointer",transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)",transform:addedId===p.id?"scale(1.2) rotate(360deg)":"scale(1)"}}>{addedId===p.id?"✓":"+"}</div>
            </div>
          </div>
        </div>
      </An>)}
    </div>
  </Phone>;
}

// ═════════════ EXPLORE ═════════════
function Explore({onNav}){
  const [sel,setSel]=useState(0);
  const [addedId,setAddedId]=useState(null);
  const add=(id,e)=>{e?.stopPropagation();setAddedId(id);setTimeout(()=>setAddedId(null),900)};
  return <Phone activeTab="explore" onNav={onNav}>
    <CurvedHeader noSearch>
      <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:12}}>
        <BackBtn onClick={()=>onNav?.("home")}/>
        <div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>🌶️ Spices & Dry Goods</div>
        <span style={{marginLeft:"auto",fontSize:12,color:"rgba(255,255,255,0.5)"}}>342 items</span>
      </div>
      <div style={{display:"flex",alignItems:"center",gap:10,padding:"11px 14px",borderRadius:12,background:"rgba(255,255,255,0.1)",border:"1px solid rgba(255,255,255,0.08)"}}>
        <span style={{fontSize:14,opacity:0.5}}>🔍</span><span style={{fontSize:13,color:"rgba(255,255,255,0.4)"}}>Search in Spices...</span>
      </div>
    </CurvedHeader>

    {/* Sub-category pills */}
    <div style={{marginTop:-20,position:"relative",zIndex:10,display:"flex",gap:7,padding:"0 16px 12px",overflowX:"auto"}}>
      {subCats.map((s,i)=><An key={i} delay={60+i*30} type="scale">
        <div onClick={()=>setSel(i)} style={{padding:"8px 16px",borderRadius:20,whiteSpace:"nowrap",fontSize:12,fontWeight:sel===i?700:500,background:sel===i?T.dark:T.card,color:sel===i?"#fff":T.textMid,border:`1.5px solid ${sel===i?T.dark:T.border}`,cursor:"pointer",transition:"all 0.25s",boxShadow:sel===i?`0 4px 12px ${T.dark}30`:T.sh}}>{s}</div>
      </An>)}
    </div>

    {/* Product list */}
    <div style={{padding:"0 16px 100px",display:"flex",flexDirection:"column",gap:10}}>
      {prods.map((p,i)=><An key={p.id} delay={150+i*50} type="right">
        <div onClick={()=>onNav?.("product")} style={{display:"flex",background:T.card,borderRadius:16,overflow:"hidden",border:`1px solid ${T.borderLight}`,cursor:"pointer",boxShadow:T.sh,transition:"all 0.3s"}} onMouseEnter={e=>e.currentTarget.style.boxShadow=T.shM} onMouseLeave={e=>e.currentTarget.style.boxShadow=T.sh}>
          <div style={{width:90,minHeight:90,background:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:36,position:"relative",flexShrink:0}}>
            {p.img}
            {p.badge&&<span style={{position:"absolute",top:6,left:6,background:p.bc||T.dark,color:"#fff",fontSize:7,fontWeight:700,padding:"2px 6px",borderRadius:4}}>{p.badge}</span>}
          </div>
          <div style={{flex:1,padding:"10px 12px",display:"flex",flexDirection:"column",justifyContent:"center"}}>
            <div style={{fontSize:14,fontWeight:700,color:T.text}}>{p.name}</div>
            <div style={{fontSize:11,color:T.textLight,marginBottom:4}}>{p.sub}</div>
            <div style={{display:"flex",alignItems:"center",justifyContent:"space-between"}}>
              <div style={{display:"flex",alignItems:"baseline",gap:6}}><Price p={p.p} d={p.d} size={17}/>{p.old&&<span style={{fontSize:11,color:T.textLight,textDecoration:"line-through"}}>£{p.old}</span>}</div>
              <div onClick={e=>add(p.id,e)} style={{width:30,height:30,borderRadius:15,border:addedId===p.id?"none":`1.5px solid ${T.border}`,background:addedId===p.id?T.lime:"transparent",display:"flex",alignItems:"center",justifyContent:"center",color:addedId===p.id?T.dark:T.textLight,fontSize:16,cursor:"pointer",transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)",transform:addedId===p.id?"scale(1.2) rotate(360deg)":"scale(1)"}}>{addedId===p.id?"✓":"+"}</div>
            </div>
          </div>
        </div>
      </An>)}
    </div>
  </Phone>;
}

// ═════════════ PRODUCT ═════════════
function Product({onNav}){
  const [qty,setQty]=useState(1);const [liked,setLiked]=useState(false);const [added,setAdded]=useState(false);
  return <Phone activeTab="home" onNav={onNav}>
    <div style={{position:"absolute",top:54,left:16,right:16,zIndex:30,display:"flex",justifyContent:"space-between"}}>
      <An delay={80} type="scale"><div onClick={()=>onNav?.("home")} style={{width:38,height:38,borderRadius:14,background:"rgba(255,255,255,0.9)",backdropFilter:"blur(8px)",display:"flex",alignItems:"center",justifyContent:"center",cursor:"pointer",boxShadow:T.sh,fontSize:15}}>←</div></An>
      <An delay={120} type="scale"><div onClick={()=>setLiked(!liked)} style={{width:38,height:38,borderRadius:14,background:liked?"#FFE8E8":"rgba(255,255,255,0.9)",backdropFilter:"blur(8px)",display:"flex",alignItems:"center",justifyContent:"center",cursor:"pointer",boxShadow:T.sh,fontSize:15,transition:"all 0.3s cubic-bezier(0.34,1.56,0.64,1)",transform:liked?"scale(1.1)":"scale(1)"}}>{liked?"❤️":"🤍"}</div></An>
    </div>
    <An delay={50} type="scale"><div style={{height:290,background:"linear-gradient(180deg,#E8F5E9 0%,#C8E6C9 50%,#F2F5EF 100%)",display:"flex",alignItems:"center",justifyContent:"center",position:"relative"}}>
      <div style={{fontSize:100,animation:"float 3s ease-in-out infinite",filter:"drop-shadow(0 16px 30px rgba(11,59,45,0.1))"}}>🍚</div>
      <div style={{position:"absolute",bottom:22,display:"flex",gap:6}}>{[0,1,2].map(i=><div key={i} style={{width:i===0?18:7,height:7,borderRadius:4,background:i===0?T.green:`${T.green}30`}}/>)}</div>
    </div></An>
    <div style={{background:T.card,borderRadius:"28px 28px 0 0",marginTop:-22,position:"relative",padding:"22px 20px 140px"}}>
      <An delay={200} type="up"><div style={{display:"flex",gap:6,marginBottom:10,flexWrap:"wrap"}}>
        {[["⚡","Fast Delivery",T.greenLight],["⭐","Best Seller",T.gold],["✓","In Stock",T.green]].map(([ic,lb,cl],i)=><span key={i} style={{display:"inline-flex",alignItems:"center",gap:4,padding:"4px 10px",borderRadius:8,background:`${cl}12`,border:`1px solid ${cl}20`,fontSize:10,fontWeight:600,color:cl}}>{ic} {lb}</span>)}
      </div></An>
      <An delay={260} type="up"><div style={{fontSize:24,fontWeight:800,color:T.text,fontFamily:"'Playfair Display',serif",marginBottom:2}}>Premium Basmati Rice</div><div style={{fontSize:13,color:T.textLight,marginBottom:14}}>5kg · Extra Long Grain · Aged 2 Years</div></An>
      <An delay={320} type="up"><div style={{display:"flex",alignItems:"center",justifyContent:"space-between",marginBottom:16}}>
        <div style={{display:"flex",alignItems:"baseline",gap:8}}><Price p={8} d={99} size={28}/><span style={{fontSize:14,color:T.textLight,textDecoration:"line-through"}}>£10.99</span></div>
        <div style={{display:"flex",alignItems:"center",gap:4}}><span style={{color:"#F9A825",fontSize:14}}>★</span><span style={{fontSize:14,fontWeight:700,color:T.text}}>4.8</span><span style={{fontSize:11,color:T.textLight}}>(142)</span></div>
      </div></An>
      <An delay={380} type="up"><div style={{padding:"13px 16px",borderRadius:14,background:T.bg,border:`1px solid ${T.borderLight}`,marginBottom:16}}><div style={{fontSize:12,color:T.textMid,lineHeight:1.6}}><b>100% satisfaction guarantee.</b> Missing, poor quality, or late? We'll make it right. <span style={{color:T.greenLight,fontWeight:600}}>Read more</span></div></div></An>
      <An delay={430} type="up"><div style={{fontSize:14,fontWeight:700,color:T.text,marginBottom:6}}>About</div><div style={{fontSize:13,color:T.textMid,lineHeight:1.7,marginBottom:16}}>Premium quality extra-long grain basmati rice, aged for 2 years for perfect flavour and aroma. Ideal for biryanis, pilafs, and everyday meals.</div></An>
      <An delay={490} type="up"><div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8}}>
        {[["⚖️","5 kg","Weight"],["🌏","South Asia","Origin"],["📦","12 mo","Shelf"]].map(([ic,v,l],i)=><div key={i} style={{textAlign:"center",padding:"10px 4px",background:T.bg,borderRadius:12,border:`1px solid ${T.borderLight}`}}>
          <div style={{fontSize:16,marginBottom:2}}>{ic}</div><div style={{fontSize:11,fontWeight:700,color:T.text}}>{v}</div><div style={{fontSize:9,color:T.textLight}}>{l}</div>
        </div>)}
      </div></An>
    </div>
    <div style={{position:"absolute",bottom:90,left:0,right:0,padding:"12px 20px",background:"rgba(255,255,255,0.96)",backdropFilter:"blur(20px)",borderTop:`1px solid ${T.border}`,display:"flex",alignItems:"center",gap:12,zIndex:30}}>
      <Qty qty={qty} onM={()=>setQty(Math.max(1,qty-1))} onP={()=>setQty(qty+1)} s={38}/>
      <div style={{flex:1}}><LimeBtn onClick={()=>{setAdded(true);setTimeout(()=>{setAdded(false);onNav?.("cart")},1000)}} style={{background:added?`linear-gradient(135deg,${T.green},${T.greenLight})`:`linear-gradient(135deg,${T.lime},${T.limeLight})`,color:added?"#fff":T.dark}}>{added?"✓ Added!":"🛒  Add to cart"}</LimeBtn></div>
    </div>
  </Phone>;
}

// ═════════════ CART ═════════════
function Cart({onNav}){
  const [items,setItems]=useState(cartData);
  const sub=items.reduce((s,i)=>s+(i.p+i.d/100)*i.qty,0);const del=3.99;
  return <Phone activeTab="cart" onNav={onNav} cartCount={items.length}>
    <CurvedHeader noSearch>
      <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:12}}>
        <BackBtn onClick={()=>onNav?.("home")}/>
        <div><div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>My Cart</div><div style={{fontSize:11,color:"rgba(255,255,255,0.5)"}}>{items.length} items</div></div>
      </div>
      <div style={{display:"flex",gap:8}}>
        <div style={{flex:1,padding:"10px 14px",borderRadius:12,background:"rgba(255,255,255,0.1)",border:"1px solid rgba(255,255,255,0.08)",fontSize:13,color:"rgba(255,255,255,0.4)"}}>Add Promo</div>
        <div style={{padding:"10px 16px",borderRadius:12,background:T.lime,color:T.dark,fontSize:12,fontWeight:700,cursor:"pointer"}}>Apply</div>
      </div>
    </CurvedHeader>
    <div style={{marginTop:-18,position:"relative",zIndex:10,padding:"0 16px 120px"}}>
      {items.map((item,i)=><An key={item.id} delay={80+i*60} type="right">
        <div style={{display:"flex",alignItems:"center",gap:12,padding:"12px 0",borderBottom:i<items.length-1?`1px solid ${T.borderLight}`:"none"}}>
          <div style={{width:56,height:56,borderRadius:14,background:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:28,flexShrink:0,border:`1px solid ${T.borderLight}`}}>{item.img}</div>
          <div style={{flex:1,minWidth:0}}><div style={{fontSize:14,fontWeight:700,color:T.text}}>{item.name}</div><div style={{fontSize:10,color:T.textLight,marginBottom:3}}>{item.sub}</div><Price p={item.p} d={item.d} size={16}/></div>
          <Qty qty={item.qty} onM={()=>setItems(items.map(x=>x.id===item.id?{...x,qty:Math.max(1,x.qty-1)}:x))} onP={()=>setItems(items.map(x=>x.id===item.id?{...x,qty:x.qty+1}:x))} s={30}/>
        </div>
      </An>)}
      <An delay={400} type="up"><div style={{marginTop:14}}>
        {[["Subtotal",`£${sub.toFixed(2)}`],["Delivery",`£${del}`],["Taxes","£0.00"]].map(([l,v])=><div key={l} style={{display:"flex",justifyContent:"space-between",marginBottom:7}}><span style={{fontSize:13,color:T.textLight}}>{l}</span><span style={{fontSize:13,fontWeight:600,color:T.text}}>{v}</span></div>)}
        <div style={{borderTop:`1.5px solid ${T.border}`,paddingTop:10,marginTop:4,display:"flex",justifyContent:"space-between",alignItems:"center"}}><span style={{fontSize:15,fontWeight:700}}>Total</span><Price p={Math.floor(sub+del)} d={Math.round(((sub+del)%1)*100)} size={22}/></div>
      </div></An>
      <An delay={500} type="up"><div style={{fontSize:10,color:T.textLight,lineHeight:1.5,marginTop:10}}>By placing your order, you agree to our <span style={{color:T.greenLight,fontWeight:600}}>Terms</span> and <span style={{color:T.greenLight,fontWeight:600}}>Privacy policy</span>.</div></An>
    </div>
    <div style={{position:"absolute",bottom:90,left:0,right:0,padding:"12px 20px",background:"rgba(255,255,255,0.96)",backdropFilter:"blur(20px)",borderTop:`1px solid ${T.border}`,zIndex:30}}>
      <LimeBtn onClick={()=>onNav?.("checkout")}>Checkout  £{(sub+del).toFixed(2)}</LimeBtn>
    </div>
  </Phone>;
}

// ═════════════ CHECKOUT ═════════════
function Checkout({onNav}){
  const [method,setMethod]=useState("delivery");const [selDate,setSelDate]=useState(1);const [selPay,setSelPay]=useState(3);const [sliding,setSliding]=useState(false);
  const dates=[{d:"SAT",n:"8",m:"Mar"},{d:"SUN",n:"9",m:"Mar"},{d:"MON",n:"10",m:"Mar"},{d:"TUE",n:"11",m:"Mar"},{d:"WED",n:"12",m:"Mar"},{d:"THU",n:"13",m:"Mar"}];
  return <Phone activeTab="cart" onNav={onNav}>
    <CurvedHeader noSearch><div style={{display:"flex",alignItems:"center",gap:12}}><BackBtn onClick={()=>onNav?.("cart")}/><div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>Checkout</div></div></CurvedHeader>
    <div style={{marginTop:-18,position:"relative",zIndex:10,padding:"0 16px 120px"}}>
      <An delay={80} type="up"><div style={{display:"flex",gap:8,marginBottom:18}}>
        {["delivery","pickup"].map(m=><div key={m} onClick={()=>setMethod(m)} style={{flex:1,padding:"13px",borderRadius:14,cursor:"pointer",background:method===m?`${T.greenLight}10`:T.card,border:`2px solid ${method===m?T.greenLight:T.border}`,display:"flex",alignItems:"center",gap:8,transition:"all 0.3s"}}><span style={{fontSize:20}}>{m==="delivery"?"🛵":"🏪"}</span><span style={{fontSize:13,fontWeight:method===m?700:500,color:method===m?T.green:T.textMid}}>{m==="delivery"?"Delivery":"Pickup"}</span></div>)}
      </div></An>
      <An delay={160} type="up"><div style={{marginBottom:18}}><div style={{fontSize:15,fontWeight:700,color:T.text,marginBottom:10}}>Choose delivery day</div>
        <div style={{display:"grid",gridTemplateColumns:"repeat(3,1fr)",gap:8}}>
          {dates.map((d,i)=><div key={i} onClick={()=>setSelDate(i)} style={{padding:"10px 6px",borderRadius:12,textAlign:"center",cursor:"pointer",background:selDate===i?`${T.lime}28`:T.card,border:selDate===i?`2px solid ${T.lime}`:`2px dashed ${T.border}`,transition:"all 0.3s"}}>
            <div style={{fontSize:9,fontWeight:600,color:T.textLight,letterSpacing:1}}>{d.d}</div><div style={{fontSize:20,fontWeight:800,color:selDate===i?T.green:T.text}}>{d.n}</div><div style={{fontSize:10,color:T.textLight}}>{d.m}</div>
          </div>)}
        </div>
      </div></An>
      <An delay={260} type="up"><div style={{marginBottom:18}}><div style={{fontSize:15,fontWeight:700,color:T.text,marginBottom:10}}>Payment method</div>
        <div style={{display:"flex",gap:8}}>
          {[["➕","Add",T.dark],["💳","Master","#EB001B"],["G","G Pay","#4285F4"],["V","Visa","#1A1F71"],["P","PayPal","#003087"]].map(([ic,lb,cl],i)=><div key={i} onClick={()=>setSelPay(i)} style={{flex:1,textAlign:"center",padding:"10px 2px",borderRadius:12,cursor:"pointer",background:selPay===i?`${T.greenLight}10`:T.card,border:`2px solid ${selPay===i?T.greenLight:T.border}`,transition:"all 0.3s"}}>
            <div style={{width:34,height:34,borderRadius:17,background:selPay===i?`${T.greenLight}18`:T.bg,display:"flex",alignItems:"center",justifyContent:"center",margin:"0 auto 3px",fontSize:i===0?14:12,fontWeight:800,color:selPay===i?T.green:cl}}>{ic}</div>
            <div style={{fontSize:9,fontWeight:selPay===i?700:500,color:selPay===i?T.green:T.textLight}}>{lb}</div>
          </div>)}
        </div>
      </div></An>
      <An delay={340} type="up">
        {[["Name on card","Vithushan"],["Card number","•••• •••• •••• 4242"]].map(([l,v])=><div key={l} style={{marginBottom:10}}><div style={{fontSize:11,color:T.textLight,marginBottom:5}}>{l}</div><div style={{padding:"12px 14px",borderRadius:12,border:`1.5px solid ${T.border}`,background:T.card,fontSize:13,fontWeight:500,color:T.text}}>{v}</div></div>)}
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
          {[["Expiry","06 / 2028"],["CVV","•••"]].map(([l,v])=><div key={l}><div style={{fontSize:11,color:T.textLight,marginBottom:5}}>{l}</div><div style={{padding:"12px 14px",borderRadius:12,border:`1.5px solid ${T.border}`,background:T.card,fontSize:13,fontWeight:500,color:T.text}}>{v}</div></div>)}
        </div>
      </An>
    </div>
    <div style={{position:"absolute",bottom:90,left:0,right:0,padding:"12px 20px",background:"rgba(255,255,255,0.96)",backdropFilter:"blur(20px)",borderTop:`1px solid ${T.border}`,zIndex:30}}>
      <div onClick={()=>{setSliding(true);setTimeout(()=>onNav?.("tracking"),1500)}} style={{width:"100%",padding:"16px",borderRadius:16,background:`linear-gradient(135deg,${T.dark},${T.darkMid})`,position:"relative",overflow:"hidden",cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center"}}>
        <div style={{position:"absolute",left:sliding?"calc(100% - 52px)":6,top:5,bottom:5,width:44,borderRadius:12,background:`${T.lime}50`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:16,transition:"left 1.2s cubic-bezier(0.16,1,0.3,1)"}}>💳</div>
        <span style={{fontSize:13,fontWeight:700,color:"rgba(255,255,255,0.7)",letterSpacing:0.5}}>{sliding?"Processing...":"Slide to pay £28.73"}</span>
      </div>
    </div>
  </Phone>;
}

// ═════════════ ORDER TRACKING ═════════════
function Tracking({onNav}){
  const [step,setStep]=useState(0);
  useEffect(()=>{const t=[setTimeout(()=>setStep(1),600),setTimeout(()=>setStep(2),1200),setTimeout(()=>setStep(3),1800)];return()=>t.forEach(clearTimeout)},[]);
  return <Phone activeTab="orders" onNav={onNav}>
    <CurvedHeader noSearch>
      <div style={{display:"flex",alignItems:"center",gap:12,marginBottom:8}}>
        <BackBtn onClick={()=>onNav?.("home")}/>
        <div><div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>Order #AFC-1043</div><div style={{fontSize:11,color:"rgba(255,255,255,0.5)"}}>Placed 2:15 PM today</div></div>
      </div>
      {/* ETA card inside header */}
      <div style={{padding:"14px 16px",borderRadius:14,background:"rgba(255,255,255,0.1)",backdropFilter:"blur(4px)",border:"1px solid rgba(255,255,255,0.08)",display:"flex",alignItems:"center",gap:14}}>
        <div style={{width:44,height:44,borderRadius:14,background:`${T.lime}25`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:22}}>🛵</div>
        <div><div style={{fontSize:12,color:"rgba(255,255,255,0.6)"}}>Estimated arrival</div><div style={{fontSize:20,fontWeight:800,color:"#fff"}}>3:05 – 3:15 PM</div></div>
      </div>
    </CurvedHeader>
    <div style={{marginTop:-18,position:"relative",zIndex:10,padding:"0 20px 100px"}}>
      {/* Driver info */}
      <An delay={100} type="up"><div style={{display:"flex",alignItems:"center",gap:12,padding:"14px 0",borderBottom:`1px solid ${T.borderLight}`,marginBottom:16}}>
        <div style={{width:42,height:42,borderRadius:21,background:`linear-gradient(135deg,${T.green},${T.greenLight})`,display:"flex",alignItems:"center",justifyContent:"center",color:"#fff",fontWeight:800,fontSize:16}}>A</div>
        <div style={{flex:1}}><div style={{fontSize:14,fontWeight:700,color:T.text}}>Ali — Your Driver</div><div style={{fontSize:11,color:T.textLight}}>Arriving in ~12 minutes</div></div>
        <div style={{width:36,height:36,borderRadius:12,background:`${T.greenLight}15`,border:`1px solid ${T.greenLight}30`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:16,cursor:"pointer"}}>📞</div>
      </div></An>

      {/* Steps */}
      {orderSteps.map((s,i)=>{
        const done=i<=step;const cur=i===step;
        return <An key={i} delay={200+i*100} type="right"><div style={{display:"flex",gap:14,marginBottom:0}}>
          <div style={{display:"flex",flexDirection:"column",alignItems:"center"}}>
            <div style={{width:32,height:32,borderRadius:16,background:done?`linear-gradient(135deg,${T.green},${T.greenLight})`:T.bg,border:done?"none":`2px solid ${T.border}`,display:"flex",alignItems:"center",justifyContent:"center",fontSize:done?13:14,color:done?"#fff":T.textLight,transition:"all 0.5s cubic-bezier(0.34,1.56,0.64,1)",transform:cur?"scale(1.12)":"scale(1)",boxShadow:cur?`0 4px 12px ${T.green}40`:"none"}}>{done?"✓":s.icon}</div>
            {i<orderSteps.length-1&&<div style={{width:2,height:28,background:done&&i<step?T.greenLight:T.border,borderRadius:1,transition:"all 0.5s"}}/>}
          </div>
          <div style={{paddingBottom:12}}>
            <div style={{fontSize:14,fontWeight:cur?700:done?600:500,color:done?T.text:T.textLight}}>{s.l}</div>
            <div style={{fontSize:11,color:T.textLight}}>{s.t}</div>
            {cur&&<div style={{fontSize:10,color:T.greenLight,fontWeight:600,marginTop:2}}>In progress...</div>}
          </div>
        </div></An>;
      })}

      {/* Order items */}
      <An delay={750} type="up"><div style={{marginTop:8,background:T.card,borderRadius:16,padding:14,border:`1px solid ${T.borderLight}`,boxShadow:T.sh}}>
        <div style={{fontSize:14,fontWeight:700,color:T.text,marginBottom:10}}>Order Items (4)</div>
        {cartData.map((item,i)=><div key={i} style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 0",borderBottom:i<cartData.length-1?`1px solid ${T.borderLight}`:"none"}}>
          <div style={{display:"flex",alignItems:"center",gap:10}}><span style={{fontSize:20}}>{item.img}</span><div><div style={{fontSize:12,fontWeight:600,color:T.text}}>{item.name}</div><div style={{fontSize:10,color:T.textLight}}>× {item.qty}</div></div></div>
          <span style={{fontSize:13,fontWeight:700,color:T.text}}>£{((item.p+item.d/100)*item.qty).toFixed(2)}</span>
        </div>)}
        <div style={{display:"flex",justifyContent:"space-between",marginTop:10,paddingTop:10,borderTop:`1.5px dashed ${T.border}`}}><span style={{fontWeight:700,fontSize:14}}>Total</span><Price p={28} d={73} size={18}/></div>
      </div></An>
    </div>
  </Phone>;
}

// ═════════════ PROFILE ═════════════
function Profile({onNav}){
  return <Phone activeTab="profile" onNav={onNav}>
    <CurvedHeader noSearch>
      <div style={{textAlign:"center",paddingBottom:8}}>
        <An delay={100} type="scale"><div style={{width:72,height:72,borderRadius:36,background:`${T.lime}30`,border:"3px solid rgba(255,255,255,0.2)",display:"flex",alignItems:"center",justifyContent:"center",margin:"0 auto 10px",fontSize:28,color:"#fff",fontWeight:800,backdropFilter:"blur(8px)"}}>V</div></An>
        <An delay={180} type="up"><div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>Vithushan</div><div style={{fontSize:12,color:"rgba(255,255,255,0.6)",marginTop:2}}>vithushan@email.com</div></An>
      </div>
    </CurvedHeader>
    <div style={{marginTop:-18,position:"relative",zIndex:10,padding:"0 16px 100px"}}>
      {/* Stats */}
      <An delay={220} type="up"><div style={{display:"flex",gap:10,marginBottom:16}}>
        {[["📦","12","Orders"],["⭐","4.8","Rating"],["💚","3","Saved"]].map(([ic,val,lb],i)=><div key={i} style={{flex:1,textAlign:"center",padding:"14px 6px",background:T.card,borderRadius:14,border:`1px solid ${T.borderLight}`,boxShadow:T.sh}}>
          <div style={{fontSize:18,marginBottom:4}}>{ic}</div><div style={{fontSize:18,fontWeight:800,color:T.text}}>{val}</div><div style={{fontSize:10,color:T.textLight}}>{lb}</div>
        </div>)}
      </div></An>

      {[["📦","My Orders","View order history",()=>onNav?.("tracking")],["📍","Saved Addresses","2 addresses"],["💳","Payment Methods","Visa •••• 4242"],["🔔","Notifications","Push enabled"],["🎁","Refer a Friend","Get £5 credit"],["🌐","Language","English (UK)"],["❓","Help & Support","FAQs, Contact us"],["📄","Terms & Privacy"]].map(([ic,title,sub,action],i)=>(
        <An key={i} delay={280+i*40} type="right">
          <div onClick={action} style={{display:"flex",alignItems:"center",padding:"13px 14px",background:T.card,borderRadius:14,marginBottom:6,border:`1px solid ${T.borderLight}`,cursor:action?"pointer":"default",boxShadow:T.sh,transition:"all 0.3s"}} onMouseEnter={e=>action&&(e.currentTarget.style.boxShadow=T.shM)} onMouseLeave={e=>e.currentTarget.style.boxShadow=T.sh}>
            <div style={{width:40,height:40,borderRadius:12,background:T.bg,display:"flex",alignItems:"center",justifyContent:"center",fontSize:18,marginRight:12}}>{ic}</div>
            <div style={{flex:1}}><div style={{fontSize:14,fontWeight:600,color:T.text}}>{title}</div>{sub&&<div style={{fontSize:11,color:T.textLight,marginTop:1}}>{sub}</div>}</div>
            <span style={{color:T.textLight,fontSize:16}}>›</span>
          </div>
        </An>
      ))}
      <An delay={600} type="up"><div style={{marginTop:8,padding:"13px",background:"#FFEBEE",borderRadius:14,textAlign:"center",cursor:"pointer"}}><span style={{fontSize:14,fontWeight:700,color:T.red}}>Sign Out</span></div></An>
    </div>
  </Phone>;
}

// ═════════════ ADMIN DASHBOARD ═════════════
function Admin({onNav}){
  return <Phone activeTab="home" onNav={onNav}>
    <CurvedHeader noSearch>
      <div style={{display:"flex",alignItems:"center",gap:12}}>
        <BackBtn onClick={()=>onNav?.("home")}/>
        <div><div style={{fontSize:11,color:"rgba(255,255,255,0.5)"}}>Admin Panel</div><div style={{fontSize:20,fontWeight:800,color:"#fff",fontFamily:"'Playfair Display',serif"}}>Amma Food City</div></div>
      </div>
    </CurvedHeader>
    <div style={{marginTop:-18,position:"relative",zIndex:10,padding:"0 16px 100px"}}>
      {/* Stats */}
      <An delay={80} type="up"><div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10,marginBottom:16}}>
        {[["📦","23","Today's Orders","+12%",T.green],["💰","£847","Revenue","+8%",T.gold],["⏳","5","Pending","",T.saffron],["🛵","3","Delivering","",T.greenLight]].map(([ic,val,lb,ch,cl],i)=><div key={i} style={{background:T.card,borderRadius:14,padding:"12px 14px",border:`1px solid ${T.borderLight}`,boxShadow:T.sh}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:6}}><span style={{fontSize:18}}>{ic}</span>{ch&&<span style={{fontSize:10,color:T.greenLight,fontWeight:600}}>{ch}</span>}</div>
          <div style={{fontSize:22,fontWeight:800,color:cl}}>{val}</div><div style={{fontSize:11,color:T.textLight}}>{lb}</div>
        </div>)}
      </div></An>

      {/* Recent orders */}
      <An delay={200} type="up"><div style={{fontSize:16,fontWeight:700,color:T.text,marginBottom:10}}>🔔 New Orders</div></An>
      {[{id:"#1043",c:"Sarah M.",n:4,t:"£28.73",tm:"2m",st:"New",sc:T.red},{id:"#1042",c:"Ahmed K.",n:7,t:"£42.50",tm:"8m",st:"Preparing",sc:T.saffron},{id:"#1041",c:"Priya S.",n:3,t:"£18.99",tm:"15m",st:"Ready",sc:T.greenLight},{id:"#1040",c:"James W.",n:5,t:"£35.20",tm:"22m",st:"Delivering",sc:T.green}].map((o,i)=>(
        <An key={i} delay={240+i*50} type="right">
          <div style={{padding:"12px 14px",background:T.card,borderRadius:14,marginBottom:6,border:`1px solid ${T.borderLight}`,boxShadow:T.sh}}>
            <div style={{display:"flex",justifyContent:"space-between",marginBottom:4}}><span style={{fontSize:13,fontWeight:700,color:T.text}}>{o.id} — {o.c}</span><span style={{fontSize:13,fontWeight:700,color:T.green}}>{o.t}</span></div>
            <div style={{display:"flex",justifyContent:"space-between"}}><span style={{fontSize:11,color:T.textLight}}>{o.n} items · {o.tm} ago</span><span style={{fontSize:10,fontWeight:700,color:o.sc,background:`${o.sc}15`,padding:"2px 8px",borderRadius:6}}>{o.st}</span></div>
          </div>
        </An>
      ))}

      {/* Quick actions */}
      <An delay={460} type="up"><div style={{fontSize:16,fontWeight:700,color:T.text,marginTop:14,marginBottom:10}}>Quick Actions</div></An>
      <An delay={500} type="up"><div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10}}>
        {[["📦","Products","1,093"],["🗂️","Categories","6"],["🛵","Delivery","4 zones"],["📊","Analytics","Reports"]].map(([ic,lb,sb],i)=><div key={i} style={{background:T.card,borderRadius:14,padding:"14px",border:`1px solid ${T.borderLight}`,boxShadow:T.sh,cursor:"pointer"}}>
          <span style={{fontSize:22}}>{ic}</span><div style={{fontSize:13,fontWeight:600,color:T.text,marginTop:6}}>{lb}</div><div style={{fontSize:10,color:T.textLight}}>{sb}</div>
        </div>)}
      </div></An>
    </div>
  </Phone>;
}

// ═════════════ MAIN ═════════════
export default function App(){
  const [screen,setScreen]=useState("splash");const [trans,setTrans]=useState(false);
  const nav=useCallback(t=>{setTrans(true);setTimeout(()=>{setScreen(t);setTrans(false)},180)},[]);
  const S={splash:<Splash onNav={nav}/>,home:<Home onNav={nav}/>,explore:<Explore onNav={nav}/>,product:<Product onNav={nav}/>,cart:<Cart onNav={nav}/>,checkout:<Checkout onNav={nav}/>,tracking:<Tracking onNav={nav}/>,profile:<Profile onNav={nav}/>,admin:<Admin onNav={nav}/>,orders:<Tracking onNav={nav}/>};
  const info=[
    {id:"splash",l:"Splash",i:"🚀",d:"Brand intro with floating food icons"},
    {id:"home",l:"Home",i:"🏠",d:"Curved header, categories, products, delivery toggle"},
    {id:"explore",l:"Explore",i:"🔍",d:"Category view with sub-category pills and list"},
    {id:"product",l:"Product",i:"📦",d:"Gallery, tags, guarantee, quantity, add to cart"},
    {id:"cart",l:"Cart",i:"🛒",d:"Promo in header, items, summary, checkout CTA"},
    {id:"checkout",l:"Checkout",i:"💳",d:"Date grid, payment icons, card form, slide-to-pay"},
    {id:"tracking",l:"Tracking",i:"📍",d:"Driver info, animated steps, order items"},
    {id:"profile",l:"Profile",i:"👤",d:"Stats, settings, menu items, sign out"},
    {id:"admin",l:"Admin",i:"⚙️",d:"Dashboard stats, orders, quick actions"},
  ];
  return <div style={{fontFamily:"'DM Sans',sans-serif",background:"linear-gradient(180deg,#EFF3ED,#E4ECE6)",minHeight:"100vh"}}>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,600;0,700;0,800;1,400&display=swap" rel="stylesheet"/>
    <div style={{background:"rgba(248,250,246,0.88)",backdropFilter:"blur(20px)",borderBottom:`1px solid ${T.border}`,padding:"14px 24px",position:"sticky",top:0,zIndex:100}}>
      <div style={{maxWidth:1100,margin:"0 auto",display:"flex",justifyContent:"space-between",alignItems:"center",flexWrap:"wrap",gap:10}}>
        <div><div style={{fontSize:22,fontWeight:800,color:T.text}}>🌿 <span style={{fontFamily:"'Playfair Display',serif"}}>Amma Food City</span> — <span style={{color:T.green}}>Full Wireframe</span></div><div style={{fontSize:12,color:T.textLight,marginTop:1}}>9 screens · Gromuse-inspired · Click through the complete user journey</div></div>
        <div style={{display:"flex",gap:3}}>{[T.dark,T.green,T.greenLight,T.lime,T.gold,T.saffron].map((c,i)=><div key={i} style={{width:16,height:16,borderRadius:5,background:c,border:"1.5px solid rgba(255,255,255,0.3)"}}/>)}</div>
      </div>
    </div>
    <div style={{maxWidth:1100,margin:"0 auto",padding:"24px",display:"flex",gap:28,flexWrap:"wrap",justifyContent:"center"}}>
      <div style={{width:240,flexShrink:0}}>
        <div style={{background:"#fff",borderRadius:22,padding:18,boxShadow:T.sh,border:`1px solid ${T.border}`,position:"sticky",top:72}}>
          <div style={{fontSize:10,fontWeight:700,color:T.textLight,letterSpacing:1.5,marginBottom:12}}>ALL SCREENS</div>
          {info.map(s=><div key={s.id} onClick={()=>nav(s.id)} style={{padding:"8px 10px",borderRadius:12,cursor:"pointer",marginBottom:3,background:screen===s.id?`${T.green}08`:"transparent",border:`1.5px solid ${screen===s.id?T.green+"20":"transparent"}`,transition:"all 0.25s"}}>
            <div style={{display:"flex",alignItems:"center",gap:8}}><span style={{fontSize:16}}>{s.i}</span><span style={{fontSize:12,fontWeight:screen===s.id?700:500,color:screen===s.id?T.green:T.text}}>{s.l}</span></div>
            <div style={{fontSize:9,color:T.textLight,marginTop:1,paddingLeft:24}}>{s.d}</div>
          </div>)}
          <div style={{marginTop:12,padding:"10px 12px",background:`${T.green}08`,borderRadius:12,border:`1px solid ${T.green}15`}}>
            <div style={{fontSize:9,fontWeight:700,color:T.green,letterSpacing:1,marginBottom:4}}>✦ DESIGN SYSTEM</div>
            <div style={{fontSize:10,color:T.textMid,lineHeight:1.7}}>Curved dark headers · Category circles on curve · Superscript £8.<sup>99</sup> pricing · Circular ⊖1⊕ qty · Lime CTAs · Dashed date picker · Slide-to-pay · Playfair Display serif</div>
          </div>
        </div>
      </div>
      <div style={{flex:1,display:"flex",justifyContent:"center"}}>
        <div style={{transition:"all 0.18s",opacity:trans?0:1,transform:trans?"scale(0.97)":"scale(1)"}}>{S[screen]}</div>
      </div>
    </div>
  </div>;
}
