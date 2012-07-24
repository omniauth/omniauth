/**
 * Add support fo CSS3 box-sizing: border-box model for IE6 and IE7
 * 
 * @author Alberto Gasparin http://albertogasparin.it/
 * @version 1.1, License MIT
 * 
 **/

var borderBoxModel=function(l,d){function m(){e=parseInt(b.width,10)||parseInt(a.width,10);f=parseInt(b.height,10)||parseInt(a.height,10);if(e){var c=parseInt(b.borderLeftWidth||a.borderLeftWidth,10)||0,g=parseInt(b.borderRightWidth||a.borderRightWidth,10)||0,h=parseInt(b.paddingLeft||a.paddingLeft,10),i=parseInt(b.paddingRight||a.paddingRight,10);if(c=c+h+i+g)a.width=e-c}if(f){c=parseInt(b.borderTopWidth||a.borderTopWidth,10)||0;g=parseInt(b.borderBottomWidth||a.borderBottomWidth,10)||0;h=parseInt(b.paddingTop||a.paddingTop,10);i=parseInt(b.paddingBottom||a.paddingBottom,10);if(c=c+h+i+g)a.height=f-c}}for(var j,b,a,e,f,k=0,n=l.length;k<n;k++){j=l[k];a=j.style;b=j.currentStyle;if(a.boxSizing==d||a["box-sizing"]==d||b.boxSizing==d||b["box-sizing"]==d)try{m()}catch(e){}}}(document.getElementsByTagName("*"),"border-box");
