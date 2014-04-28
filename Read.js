function ResizeImages(maxwidth) {
    
    var myImg,oldwidth;
   // var maxwidth=320; //缩放系数
    for(i=0;i <document.images.length;i++){
        myImg = document.images[i];
        var div = myImg.parentNode;
        div.style.marginLeft = 0 +"px";
        if(myImg.width > maxwidth)
        {
            oldwidth = myImg.width;
            myImg.width = maxwidth;
            myImg.height = myImg.height * (maxwidth/oldwidth);
        }
    }
 
}
 function Touch()
{
    alert("开始调用");
    var myItem;
    for(i = 0;i<document.elements.length;i++)
    {
        myItem = document.elements[i];
        myItem.onclick = al;
    }
//    alert('好吧');
//    element.addEventListener("touchstart",touchStart,false);
//    document.onclick = al;//加上括号就是立即执行。

}
function al()
{
    alert ('Hello&&&&&&&');

}


//document.body.onclick= al;

