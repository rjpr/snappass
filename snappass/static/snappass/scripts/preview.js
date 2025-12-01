(function () {

  document.getElementById('revealSecret').addEventListener('click', function () {
    var form = document.createElement('form');
    form.id = 'revealSecretForm';
    form.method = 'post';
    document.body.appendChild(form);
    form.submit();
  });

})();