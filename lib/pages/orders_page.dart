import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order.dart';
import 'package:shop/models/orderList.dart';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      body: FutureBuilder(
        future: Provider.of<OrderList>(context, listen: false).loadOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return const Center(child: Text('Ocorreu um erro!'));
          } else {
            return Consumer<OrderList>(builder: (ctx, orders, child) {
              return RefreshIndicator(
                onRefresh: () => orders.loadOrders(),
                child: ListView.builder(
                  itemCount: orders.itensCount,
                  itemBuilder: (ctx, i) => OrderWidget(order: orders.itens[i]),
                ),
              );
            });
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
