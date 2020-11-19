"use strict";

// Options
var g_showFocus = false;      // show focus indicator or not

// State
var g_focus = false;          // if Widget has the focus or not
var g_data = '';              // Buffer to defer set data until focus


/*
** element_Select: Select an element object, set data and notify via action
** @param {object} Data item contains {x,value,id,index,name}
** @param {object} HTML Element
*/
function element_Select(o_data, o_element)
{
  // Focus needed to set data
  gICAPI.SetFocus();

  if (o_data)
    var p_data = JSON.stringify(o_data);
  else
    return;
    
  if (g_focus)
    data_Send(p_data, 'select');
  else
    g_data = p_data; //deferred until onFocus

  //%D: alert(p_data);
}


/*
** data_Send: Set data and Send action to notify DVM
** @param {string} data
** @param {string} Action
*/
function data_Send(p_data, p_action)
{
  gICAPI.SetData(p_data);
  gICAPI.Action(p_action);
}


var onICHostReady = function(p_version)
{
    if (p_version != "1.0")
      {
      alert('Invalid API version');
      }

    // When the DVM set/remove the focus to/from the component
    gICAPI.onFocus = function(p_polarity)
      {
      if (p_polarity)
        {
        g_focus = true;
        if (g_showFocus)
          $('body').css('border', '3px solid #7FAFEB');

        // Used to send deferred Data when we have focus
        if (g_data)
          {
          data_Send(g_data, 'select');
          g_data = '';
          }
        }
      else
        {
        g_focus = false;
        if (g_showFocus)
          $('body').css('border', 'none');
        }
      }

    // When the component property changes
    gICAPI.onProperty = function(p_property)
      {
      var o_prop = eval('(' + p_property + ')');

      //
      // Set properties for 
      //

      //.title
      if (o_prop.title)
        {
        $('#Title').html(o_prop.title);
        $('#Title').show();
        }

      //.narrative
      if (o_prop.narrative)
        {
        $('#Narrative').html(o_prop.narrative);
        $('#Narrative').show();
        }

      //.showfocus
      g_showFocus = (o_prop.showfocus == true);
      }

    // When field data changes
    gICAPI.onData = function(p_value)
      {
      }
}




//
// PUBLIC ///////////////////////////////////
//

/*
** Set: Set contents of the chart structured in JSON
** @param {string} JSON document of the chart definition 
*/
function Set(p_chart)
{
  //%D: alert('Set: ' + p_chart);
  
  // Reset: clear or hide everything  
  if (p_chart)
    {
    // data defined, grab Accordion record
    var r_chart = JSON.parse(p_chart);

    //.title
    if (r_chart.title)
      {
      $('#Title').html(r_chart.title);
      $('#Title').show();
      }

    //.narrative
    if (r_chart.narrative)
      {
      $('#Narrative').html(r_chart.narrative);
      $('#Narrative').show();
      }

      //.showfocus
      g_showFocus = (r_chart.showfocus == true);

    // Add onClick
    r_chart.doc.data.onclick = function (d,e) {element_Select(d,e);};
    
    // Generate chart
    c3.generate(r_chart.doc);
    }
}


