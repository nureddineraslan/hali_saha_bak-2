import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/comment.dart';
import 'package:hali_saha_bak/screens/User/ReservationDetail/reservation_detail.dart';
import 'package:hali_saha_bak/widgets/comment_widget.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maç Özeti'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Center(
                    child: Stack(
                      children: [
                        Image.asset('assets/images/video.png'),
                        Center(
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [Icon(Icons.share), SizedBox(width: 6), Text('Paylaş')],
                  ),
                  Row(
                    children: [Icon(Icons.favorite), SizedBox(width: 6), Text('Beğen')],
                  ),
                  Row(
                    children: [Icon(Icons.download), SizedBox(width: 6), Text('İndir')],
                  )
                ],
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoWidget(
                      infoKey: 'Maçın Adamı',
                      value: 'Emre',
                      equalFlex: true,
                    ),
                    InfoWidget(
                      infoKey: 'Atılan Goller',
                      value: "23. Emre \n64. Ali \n87. Onur",
                      equalFlex: true,
                    ),
                    InfoWidget(
                      infoKey: 'En İyi Golun Sahibi',
                      value: 'Onur',
                      equalFlex: true,
                    ),
                    InfoWidget(
                      infoKey: 'Skor',
                      value: '2 - 1',
                      equalFlex: true,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Yorumlar',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    CommentWidget(
                      comment: Comment(
                        id: 1,
                        rating: 5,
                        message: 'Çok iyi maçtı',
                        userUID: '123',
                        username: 'Fatih',
                        userProfilePicUrl: null,
                        haliSahaId: '1234',
                        createdDate: DateTime.now().subtract(
                          Duration(days: 1),
                        ),
                      ),
                    ),
                    CommentWidget(
                      comment: Comment(
                        id: 1,
                        rating: 5,
                        message: 'Mükemmel',
                        userUID: '123',
                        username: 'Emre',
                        userProfilePicUrl: null,
                        haliSahaId: '1234',
                        createdDate: DateTime.now().subtract(
                          Duration(days: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
