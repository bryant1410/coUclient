part of couclient;

class ActionBubble {
  int duration;

  SpanElement outline = new SpanElement();
  SpanElement fill = new SpanElement()
  ActionBubble(String text, this.duration) {
    // Position the action bubble
    num posX = CurrentPlayer.posX;
    num posY = CurrentPlayer.posY;
    int width = CurrentPlayer.width;
    int height = CurrentPlayer.height;
    num translateX = posX, translateY = view.worldElement.clientHeight - height;
    if(posX > currentStreet.bounds.width - width/2 - view.worldElement.clientWidth/2)
      translateX = posX - currentStreet.bounds.width + view.worldElement.clientWidth;
    else if(posX + width/2 > view.worldElement.clientWidth/2)
      translateX = view.worldElement.clientWidth/2 - width/2;
    if(posY + height/2 < view.worldElement.clientHeight/2)
      translateY = posY;
    else if(posY < currentStreet.bounds.height - height/2 - view.worldElement.clientHeight/2)
      translateY = view.worldElement.clientHeight/2 - height/2;
    else
      translateY = view.worldElement.clientHeight - (currentStreet.bounds.height - posY);
    int x = (translateX+menu.clientWidth+10)~/1;
    int y = (translateY+height/2)~/1;

    outline
      ..text = (option[0] as String).split("|")[1]
      ..className = "border"
      ..style.top  = '$y' 'px'
      ..style.left = '$x' 'px';
    fill
      ..text = (option[0] as String).split("|")[1]
      ..className = "fill" + " " + (option[0] as String).split("|")[1]
      ..style.transition = "width ${duration/1000}s linear"
      ..style.top  = '$y' 'px'
      ..style.left = '$x' 'px';

    document.body..append(outline)..append(fill);

    //start the "fill animation"
    fill.style.width = outline.clientWidth.toString()+"px";
  }

  Future get wait {

    StreamSubscription escListener;
    Timer miningTimer = new Timer(new Duration(milliseconds:duration+300), ()
    {
      outline.remove();
      fill.remove();

      // DONE

      escListener.cancel();
    });

    escListener = document.onKeyUp.listen((KeyboardEvent k)
    {
      if(k.keyCode == 27)
      {

        // DONE

        outline.remove();
        fill.remove();
        escListener.cancel();
        miningTimer.cancel();
      }
    });
  }
}