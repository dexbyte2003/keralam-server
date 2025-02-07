// html/script.js
window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === 'update') {
        document.getElementById('server-name').innerText = data.data.serverName;
        document.getElementById('player-id').innerText = "#" + data.data.playerId;
        document.getElementById('player-name').innerText = data.data.playerName;
        document.getElementById('cash').innerText =  "$" + data.data.cash;
        document.getElementById('bank').innerText = "$" + data.data.bank;
        document.getElementById('job').innerText = data.data.jobLabel + "/" + data.data.job;
        document.getElementById('job-role').innerText = data.data.jobGrade;
    }
});
