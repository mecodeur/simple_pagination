import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final dio = Dio();

  List products = [];
  int skip = 0;
  int limit = 10;
  bool isLoading = false;

  ScrollController scrollController = ScrollController();

   getProducts() async {
    final response =
        await dio.get('https://dummyjson.com/products?limit=$limit&skip=$skip');

    var result = List.from(response.data['products'].map((e) => e));

    setState(() {
      products.addAll(result);
    });
  }

  @override
  void initState() {
    getProducts();

    scrollController.addListener(() async {
      if(isLoading) return;
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
        setState(() {
          isLoading = true;
        });
        skip = skip + limit;
        await getProducts();

        setState(() {
          isLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagination'),
      ),
      body: Container(
        child: ListView.builder(
          controller: scrollController,
          itemCount: isLoading ? products.length+1 : products.length,
          itemBuilder: (BuildContext context, int index) {

              if(index >= products.length){
                return Center(child: CircularProgressIndicator());
              }else{
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown.shade800,
                      child: Image.network(products[index]['thumbnail']),
                    ),
                    title: Text(products[index]['title']),
                    subtitle: Text(products[index]['description']),
                  ),
                );
              }

          },
        ),
      ),
    );
  }
}
