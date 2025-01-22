import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main(){
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      )
          .copyWith(
        textTheme: GoogleFonts.alataTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const Page1(),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  int pageId =0;
  ValueNotifier<List<dynamic>> lists = ValueNotifier<List<dynamic>>([]);
  ScrollController scrollController = ScrollController();
  Throttle throttle = Throttle(const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async{
      lists.value = await fetchList();
    });
    scrollController.addListener(onEndReach);
  }

  void onEndReach(){
    if(scrollController.position.pixels>=scrollController.position.maxScrollExtent-50){
      throttle.run(()async{
       lists.value =  [...lists.value,...(await fetchList())];
      });
    }
  }

  Future<Map<String,dynamic>> fetchTileData(String articleId)async{
    try{
      final response =  await http.post(Uri.parse("https://api.mymfbox.com/article/getArticlesDetails?key=50732c09-87d6-4208-b843-72aef02fb2cd&user_id=650923&client_name=eureka&article_id=$articleId"));
      if(response.statusCode==200){
        return jsonDecode(response.body)['article']??{};
      }
      throw Exception("status code is not 200");
    }catch(e){
      log("error occured: ",error: e);
      return {};
    }
  }



  Future<List<dynamic>> fetchList()async{
   try{
    final response =  await http.post(Uri.parse("https://api.mymfbox.com/article/getArticles?key=50732c09-87d6-4208-b843-72aef02fb2cd&user_id=650923&client_name=eureka&page_id=${++pageId}&type=recent&category=&author=&search="));
    if(response.statusCode==200){
      return jsonDecode(response.body)['article_list'];
    }
    throw Exception("status code is not 200");
   }catch(e){
     log("error occured: ",error: e);
     return [];
   }
  }

  void navigateToViewPage(int articleId,String shortContent, BuildContext context)async{
    final data = await fetchTileData(articleId.toString());
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ViewPage(data: data,shortContent: shortContent,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(173, 216, 230, 1),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 102,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Blogs"),
            SizedBox(
              height: 5,
            ),
            TextField(
              decoration: InputDecoration(
                constraints: BoxConstraints(
                  maxHeight: 50,
                )
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: lists,
              builder: (context,data,_) {
                return ListView.builder(
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context,index){
                      return Container(
                        height: 400,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin:const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white
                        ),
                        child: GestureDetector(
                          onTap: ()=>navigateToViewPage(data[index]['article_id'],data[index]['short_content'],context),
                          child: Center(child:Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                     "${data[index]['photo_name']}",
                                    errorBuilder: (context,e,st)=>const Text("Error Loading image"),
                                  )),
                              const SizedBox(height: 10,),
                              Text(data[index]['title'].toString(),textAlign: TextAlign.left,),
                              const SizedBox(height: 10,),
                              SizedBox(
                                  width: 350,
                                  child: Text(
                                    data[index]['short_content'].toString(),
                                    style: const TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,))
                            ],
                          )),
                        ),
                      );
                    }
                );
              }
            ),
          )
        ],
      ),
    );
  }
}

class ViewPage extends StatefulWidget {
  final String shortContent;
  final Map<String,dynamic> data;
  const ViewPage({super.key, required this.data,required this.shortContent});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  late final controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)..loadHtmlString(widget.data['content']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        toolbarHeight: 102,
        leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(widget.data['title']??""),
            // Text("${widget.data['create_date']} by ${widget.data['author_name']}",style: TextStyle(color: Colors.grey),),
            // ClipRRect(
            //     borderRadius: BorderRadius.circular(15),
            //     child: Image.network(
            //       "${widget.data['photo_name']}",
            //       errorBuilder: (context,e,st)=>const Text("Error Loading image"),
            //     )),
            // const SizedBox(height: 20,),
            Expanded(child: WebViewWidget(
                controller: controller))
          ],
        ),
      ),
    );
  }
}


class Throttle{
  final Duration duration;
  Throttle(this.duration);
  Timer? timer;
  void run(void Function() func ){
    if(timer?.isActive??false){
      return;
    }
    timer = Timer(duration, (){
      func();
    });
  }
}