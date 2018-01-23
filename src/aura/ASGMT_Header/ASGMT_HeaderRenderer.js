({
  // Your renderer method overrides go here
  afterRender: function(component, helper) {
    // this.superAfterRender();
    // interact with the DOM here

    // Please note that this workaround would work if Locker service is not enabled in your Org.
    //Full Header
    //document.getElementsByClassName('slds-grid--align-spread')[1].style.display='none';

    //Search Bar
    //document.getElementsByClassName('slds-global-header__item--search')[1].style.display = 'none';
  }
})