document.addEventListener('turbo:load', function() {
  const notification = document.querySelector('.js_notification');
  if (notification) {

    const originalHeight = notification.offsetHeight;

    setTimeout(function() {
      notification.style.opacity = '0';
      notification.style.height = '0';
      notification.style.marginTop = '0';
      notification.style.marginBottom = '0';
      notification.style.paddingTop = '0';
      notification.style.paddingBottom = '0';
      notification.style.transition = 'opacity 0.5s, height 0.5s, margin 0.5s, padding 0.5s';

      setTimeout(function() {
        notification.style.display = 'none';
        notification.style.height = originalHeight + 'px';
        notification.style.removeProperty('opacity');
        notification.style.removeProperty('margin-top');
        notification.style.removeProperty('margin-bottom');
        notification.style.removeProperty('padding-top');
        notification.style.removeProperty('padding-bottom');
        notification.style.removeProperty('transition');
      }, 300);
    }, 3000);
  }
});