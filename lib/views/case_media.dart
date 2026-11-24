import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Offline, original, topic-aware editorial art. No external assets, no
/// misleading photographs, no network dependency. Changes when comparing the
/// repost with its supposed source so the comparison is visually actionable.
class CaseMedia extends StatelessWidget {
  final String topic;
  final String caption;
  final String sourceCaption;
  final bool original;
  final double height;
  /// Optional corner label, e.g. 'VIDEO'. Defaults to SHARED POST / ORIGINAL VIEW.
  final String? badge;
  const CaseMedia({super.key,required this.topic,required this.caption,this.sourceCaption='SOURCE VIEW',this.original=false,this.height=196,this.badge});

  @override Widget build(BuildContext context) {
    final icon = switch(topic){
      'Drag Race' => Icons.auto_awesome_rounded,
      'Government' => Icons.account_balance_rounded,
      'Campus' => Icons.school_rounded,
      'Basketball memorial' => Icons.sports_basketball_rounded,
      'Shopping' => Icons.local_shipping_rounded,
      'Delivery' => Icons.inventory_2_rounded,
      'Weather' => Icons.thunderstorm_rounded,
      'Music' => Icons.music_note_rounded,
      'Health' => Icons.medical_services_rounded,
      'AI' => Icons.smart_toy_rounded,
      'Election' => Icons.how_to_vote_rounded,
      _ => Icons.newspaper_rounded,
    };
    final colors = switch(topic){
      'Drag Race' => [const Color(0xFF602C90),const Color(0xFFF87AB6)],
      'Government' => [const Color(0xFF125D79),const Color(0xFF65C2D9)],
      'Campus' => [const Color(0xFF4262A3),const Color(0xFF9ED9DE)],
      'Basketball memorial' => [const Color(0xFF8D4D39),const Color(0xFFE9B36F)],
      'Weather' => [const Color(0xFF29557A),const Color(0xFF8CC8E8)],
      'Music' => [const Color(0xFFB03A7C),const Color(0xFFFFB86B)],
      'Health' => [const Color(0xFF1F7A6D),const Color(0xFFA6E6C9)],
      'AI' => [const Color(0xFF3B3B8F),const Color(0xFF7FE0E6)],
      'Election' => [const Color(0xFF8A3A3A),const Color(0xFFF2C46B)],
      _ => [const Color(0xFF515895),const Color(0xFFB18DC9)],
    };
    return SizedBox(height:height,width:double.infinity,child:ClipRRect(
      borderRadius:BorderRadius.circular(15),
      child:Stack(children:[
        Positioned.fill(child:CustomPaint(painter:_PosterPainter(colors[0],colors[1],topic,original))),
        Align(alignment:Alignment.center,child:Container(
          width:124,height:124,
          decoration:BoxDecoration(color:paperWhite.withValues(alpha:.18),shape:BoxShape.circle,border:Border.all(color:paperWhite.withValues(alpha:.38),width:3)),
          child:Icon(icon,size:76,color:paperWhite),
        )),
        Positioned(top:11,left:11,child:Container(
          padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),
          decoration:BoxDecoration(color:midnight.withValues(alpha:.82),borderRadius:BorderRadius.circular(8)),
          child:Text(badge??(original?'ORIGINAL VIEW':'SHARED POST'),style:typewriter(11,color:paperWhite)),
        )),
        Positioned(left:9,right:9,bottom:9,child:Container(
          padding:const EdgeInsets.symmetric(horizontal:9,vertical:8),
          decoration:BoxDecoration(color:midnight.withValues(alpha:.84),borderRadius:BorderRadius.circular(9)),
          child:Text(original?_shorten(sourceCaption):_shorten(caption),textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:captionText(13,color:paperWhite,weight:FontWeight.bold)),
        )),
      ]),
    ));
  }

  static String _shorten(String s) {
    final cleaned=s.replaceAll(RegExp(r'\s+'),' ').trim();
    return cleaned.length>73?'${cleaned.substring(0,73)}…':cleaned;
  }
}

class _PosterPainter extends CustomPainter {
  final Color first,second;
  final String topic;
  final bool original;
  const _PosterPainter(this.first,this.second,this.topic,this.original);
  @override void paint(Canvas canvas,Size size){
    final rectangle=Offset.zero & size;
    canvas.drawRect(rectangle,Paint()..shader=LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:original?[second,first]:[first,second]).createShader(rectangle));
    final white=Paint()..color=Colors.white.withValues(alpha:.19);
    final line=Paint()..color=Colors.white.withValues(alpha:.25)..strokeWidth=1.6;
    for(var x=0.0;x<size.width;x+=25){canvas.drawLine(Offset(x,0),Offset(x+85,size.height),line);}
    final orb=Offset(size.width*.78,size.height*.22);
    canvas.drawCircle(orb,size.height*.37,white);
    canvas.drawCircle(Offset(size.width*.14,size.height*.89),size.height*.4,white);
    for(var i=0;i<13;i++){
      final x=((i*67.0)%math.max(1,size.width));
      final y=((i*37.0)%math.max(1,size.height));
      canvas.drawCircle(Offset(x,y),i%3==0?3.2:1.6,Paint()..color=paperWhite.withValues(alpha:.62));
    }
    // A stylized scene silhouette is more recognizably visual than a flat text card.
    final shadow=Paint()..color=midnight.withValues(alpha:.21);
    switch(topic){
      case 'Government':
      case 'Campus':
      case 'Election':
        final roof=Path()..moveTo(size.width*.19,size.height*.73)..lineTo(size.width*.49,size.height*.36)..lineTo(size.width*.79,size.height*.73)..close();
        canvas.drawPath(roof,shadow);
        for(var j=0;j<5;j++){
          final x=size.width*(.28+j*.105);
          canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,size.height*.69,size.width*.05,size.height*.2),const Radius.circular(3)),shadow);
        }
        break;
      case 'Drag Race':
        for(var i=0;i<4;i++){
          final p=Path()..moveTo(size.width*(i*.30),0)..lineTo(size.width*(.25+i*.23),size.height*.95)..lineTo(size.width*(.39+i*.22),size.height*.95)..close();
          canvas.drawPath(p,white);
        }
        break;
      case 'Basketball memorial':
        canvas.drawCircle(Offset(size.width*.5,size.height*.55),size.height*.52,Paint()..color=const Color(0xFFEA8B4B).withValues(alpha:.18));
        canvas.drawLine(Offset(0,size.height*.5),Offset(size.width,size.height*.5),line..strokeWidth=4);
        break;
      default:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*.07,size.height*.55,size.width*.23,size.height*.4),const Radius.circular(9)),shadow);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width*.7,size.height*.38,size.width*.24,size.height*.52),const Radius.circular(9)),shadow);
    }
  }
  @override bool shouldRepaint(covariant _PosterPainter old)=>first!=old.first||second!=old.second||topic!=old.topic||original!=old.original;
}
