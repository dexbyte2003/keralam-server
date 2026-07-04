/* ======================================================
   🔒 HARD BLOCK UI ON LOAD (NO FLASH, NO OVERLAY)
====================================================== */

const app = document.getElementById("app");
document.body.style.display = "none";
app.classList.add("hidden");

/* ======================================================
   📦 ELEMENT REFERENCES
====================================================== */

const closeBtn = document.getElementById("closeBtn");
const spawnBtn = document.getElementById("spawnBtn");
const navButtons = document.querySelectorAll(".nav-btn");
const tabs = document.querySelectorAll(".tab");

/* ======================================================
   🔫 WEAPON DATA
====================================================== */

const weapons = {
    pistol: [
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_PISTOL50"
    ],
    smg: [
        "WEAPON_SMG",
        "WEAPON_MICROSMG",
        "WEAPON_ASSAULTSMG"
    ],
    rifle: [
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_CARBINERIFLE",
        "WEAPON_SPECIALCARBINE"
    ],
    shotgun: [
        "WEAPON_PUMPSHOTGUN",
        "WEAPON_SAWNOFFSHOTGUN"
    ],
    melee: [
        "WEAPON_KNIFE",
        "WEAPON_BAT"
    ]
};

const weaponCategory = document.getElementById("weaponCategory");
const weaponSelect = document.getElementById("weaponSelect");

/* ======================================================
   🔄 WEAPON DROPDOWN HANDLER
====================================================== */

function updateWeaponList() {
    weaponSelect.innerHTML = "";
    weapons[weaponCategory.value].forEach(w => {
        const opt = document.createElement("option");
        opt.value = w;
        opt.textContent = w.replace("WEAPON_", "");
        weaponSelect.appendChild(opt);
    });
}

weaponCategory.addEventListener("change", updateWeaponList);
updateWeaponList();

/* ======================================================
   📩 NUI MESSAGE HANDLER
====================================================== */

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "open") {
        document.body.style.display = "block";
        app.classList.remove("hidden");
    }

    if (data.action === "close") {
        app.classList.add("hidden");
        document.body.style.display = "none";
    }
});

/* ======================================================
   ❌ CLOSE UI
====================================================== */

function closeUI() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
    });
}

closeBtn.addEventListener("click", closeUI);

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
        closeUI();
    }
});

/* ======================================================
   🧭 TAB SWITCHING
====================================================== */

navButtons.forEach(btn => {
    btn.addEventListener("click", () => {
        const target = btn.dataset.tab;

        navButtons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");

        tabs.forEach(tab => {
            tab.classList.toggle("active", tab.id === `tab-${target}`);
        });
    });
});

/* ======================================================
   🧍 SPAWN NPC (WITH WEAPON DATA)
====================================================== */

spawnBtn.addEventListener("click", () => {
    const model = document.getElementById("pedModel").value.trim();
    if (!model) {
        alert("Ped model is required");
        return;
    }

    const payload = {
        model: model,
        count: parseInt(document.getElementById("spawnCount").value) || 1,
        formation: document.getElementById("formation").value,
        spacing: 1.5,

        spawn: {
            useRaycast: true,
            useGroundSnap: true,
            randomRadius: parseFloat(document.getElementById("radius").value) || 0,
            heading: "player"
        },

        states: {
            invincible: false,
            ragdoll: true,
            collision: true,
            frozen: false,
            invisible: false
        },

        behavior: {
            type: "aggressive"
        },

        combat: {
            enabled: document.getElementById("combatEnabled").checked,
            weapon: weaponSelect.value,
            infiniteAmmo: document.getElementById("infiniteAmmo").checked,
            accuracy: parseInt(document.getElementById("accuracy").value),
            aggression: parseInt(document.getElementById("aggression").value),
            useCover: document.getElementById("useCover").checked
        }
    };

    fetch(`https://${GetParentResourceName()}/spawnNpc`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
    });
});
