import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_luxe_house/screens/base_screen.dart';

class AboutAndContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'About Us & Contact Us',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 238, 242, 249),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'รับซื้อ ขาย เทรด นาฬิกาแบรนด์เนมของแท้',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About Luxe House',
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Divider(color: Colors.grey[300], thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'หากคุณคือผู้ที่หลงใหลในเสน่ห์ของนาฬิกาหายาก ผู้ที่ชื่นชอบในความงามและความประณีตของกลไกอันซับซ้อนที่ถ่ายทอดผ่านหน้าปัดของเรือนเวลา ผลิตจากวัสดุที่เลิศหรูและทรงคุณค่า และมีสไตล์เป็นของตนเองไม่ตามกระแส เราคือแหล่งรวมแบรนด์นาฬิกาชั้นนำจากทุกมุมโลก ที่จะตอบสนองความต้องการและความพิถีพิถันของคุณได้อย่างสมบูรณ์แบบ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),
                    SizedBox(height: 24),
                    Text(
                      'ยินดีต้อนรับเข้าสู่ Luxe House',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Divider(color: Colors.grey[300], thickness: 1),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white, 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildContactInfo(
                                FontAwesomeIcons.store,
                                'Luxe House',
                                'Store Name',
                              ),
                            ),
                            Expanded(
                              child: _buildContactInfo(
                                FontAwesomeIcons.mapMarkerAlt,
                                'Owl House9, Kamphaeng Saen, Nakhon Pathom',
                                'Address',
                              ),
                            ),
                            Expanded(
                              child: _buildContactInfo(
                                FontAwesomeIcons.phoneAlt,
                                '+66 095-067-0987',
                                'Phone',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildContactInfo(
                                FontAwesomeIcons.envelope,
                                'keeratinan.p@gmail.com',
                                'Email',
                              ),
                            ),
                            Expanded(
                              child: _buildAdditionalInfo(
                                'Opening Hours:',
                                'Mon - Fri: 10:00 AM - 7:00 PM\nSat - Sun: 11:00 AM - 5:00 PM',
                              ),
                            ),
                            Expanded(
                              child: _buildFollowUs(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Follow Us:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _launchURL('https://www.facebook.com/keeratinan.putthaya.33/'),
              child: Icon(
                FontAwesomeIcons.facebook,
                color: Colors.blue,
                size: 30,
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => _launchURL('https://instagram.com/unrices'),
              child: Icon(
                FontAwesomeIcons.instagram,
                color: Colors.purple,
                size: 30,
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => _launchURL('https://line.me/R/ti/p/@341dtdpi'),
              child: Icon(
                FontAwesomeIcons.line,
                color: Colors.green,
                size: 30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildContactInfo(IconData icon, String info, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.black54,
          size: 20,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Text(
          info,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(String title, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Text(
          info,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
