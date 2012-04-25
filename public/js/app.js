
$(document).ready(function(){            
    var grid = new hashgrid();

    // Opt-in to tooltips
    $('a[rel=tooltip]').tooltip({
        placement : 'top'
    });



    $('#loginform').submit(function() { 
        // inside event callbacks 'this' is the DOM element so we first 
        // wrap it in a jQuery object and then invoke ajaxSubmit 
        $(this).ajaxSubmit(); 
 
        // !!! Important !!! 
        // always return false to prevent standard browser submit and page navigation 
        return false; 
    }); 


});

