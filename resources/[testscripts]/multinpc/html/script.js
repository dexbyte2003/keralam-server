window.addEventListener('message', function(event) {
    if (event.data.type === "open") {
        $("#app").fadeIn(200);
    } 
    else if (event.data.type === "close") {
        $("#app").fadeOut(200);
    }
    else if (event.data.type === "updateList") {
        updateList(event.data.peds);
    }
});

$("#close-btn").click(function() {
    $.post('https://multinpc/close', JSON.stringify({}));
    $("#app").fadeOut(200);
});

$("#spawn-btn").click(function() {
    let model = $("#model-input").val();
    if(model) {
        $.post('https://multinpc/spawn', JSON.stringify({ model: model }));
        $("#model-input").val(""); // clear input
    }
});

function updateList(peds) {
    $("#npc-list").empty();
    peds.forEach(ped => {
        $("#npc-list").append(`
            <div class="npc-item">
                <span>${ped.model} (ID:${ped.id})</span>
                <div class="btn-group">
                    <button onclick="playChar(${ped.id})">Play</button>
                    <button class="btn-del" onclick="deleteChar(${ped.id})">Del</button>
                </div>
            </div>
        `);
    });
}

// These functions are global so the HTML onclick can see them
window.playChar = function(id) {
    $.post('https://multinpc/play', JSON.stringify({ id: id }));
}

window.deleteChar = function(id) {
    $.post('https://multinpc/delete', JSON.stringify({ id: id }));
}

// Close on Escape key
document.onkeyup = function (data) {
    if (data.which == 27) { // Escape key
        $.post('https://multinpc/close', JSON.stringify({}));
        $("#app").fadeOut(200);
    }
};