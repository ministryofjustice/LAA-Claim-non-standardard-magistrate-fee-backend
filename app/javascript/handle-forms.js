import $ from 'jquery'

window.$ = $

let formsDisabled = false;

$(function() {
  $('button[type="submit"]:not([data-disable="false"])').on("click", function(e) {
    e.preventDefault()
    let form = $(this).closest("form")
    let formButtons = form.find('button[type="submit"]')
    formButtons.each(function(){
      $(this).attr("disabled", true)
      this.dataset.disabledOnSubmit = "true";
    })

    formsDisabled = true

    /*
      this code ensures the button's submission type is appended to params
      so that the BaseStepController still has this available to know
      whether the form should commit_draft/save_and_refresh/reload
    */
    let buttonAction = $(this).attr("name")
    if(buttonAction){
      form.append(`<input id="dummy-submit" type="hidden" name="${buttonAction}" value="" >`)
    }

    form.trigger('submit.rails')
  })
})

window.addEventListener( "pageshow", function ( event ) {
  const navEntries = window.performance?.getEntriesByType('navigation').map((nav) => nav.type)
  const pageAccessedByBrowserNavigation = (
    navEntries &&
    (navEntries.includes('reload') || navEntries.includes('navigate'))
  );

  // The disable-on-submit logic means that if you are on the page after a form
  // and you then click the browser back button, you may find that the browser
  // does not reload the page, it merely rerenders it in its previous state -
  // i.e. with the form still disabled. To get around this we need to reload
  // the page if it is accessed by the browser back button.

  // Weirdly, when the browser back button is used, `pageshow` triggers with
  // a navigation entry either of type `reload` or type `navigate` depending
  // on the quirks of Chrome. By itself, this trigger
  // doesn't allow us to distinguish between an actual reload event and a
  // 're-show-due-to-back-button-use event. However, in the latter case
  // the JS will not have been reinitialised so the `formsDisabled` variable
  // will still be set to true if a form has been disabled. So if both
  // those conditions hold we know that this is a re-show-due-to-back-button-use
  //  and we can do a real reload to un-disable the form
  if (pageAccessedByBrowserNavigation && formsDisabled) {
    this.document.getElementById('dummy-submit')?.remove();
    [...document.querySelectorAll('button[type="submit"][data-disabled-on-submit="true"]')].forEach((button) => {
      button.removeAttribute('disabled');
      button.dataset.disabledOnSubmit = "false";
    })
  }

});
