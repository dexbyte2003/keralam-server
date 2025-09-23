(() => {
  const notify = document.getElementById('kill-notify');
  let hideTimer = null;

  window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'showKill') {
      notify.querySelector('.skull').textContent = data.emoji || "💀";
      notify.classList.add('show');
      clearTimeout(hideTimer);
      hideTimer = setTimeout(() => {
        notify.classList.remove('show');
      }, data.duration || 1600);
    }
  });
})();
