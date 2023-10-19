import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/order.dart';
import 'package:shop/models/orderList.dart';
import 'package:intl/intl.dart';

class OrderWidget extends StatefulWidget {
  final Order order;
  const OrderWidget({super.key, required this.order});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'R\$ ${widget.order.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.date),
            ),
            trailing: IconButton(
              icon: Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                height: widget.order.products.length * 25 + 10,
                child: ListView(
                  children: widget.order.products.map((prod) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prod.name,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${prod.quantity}x R\$ ${prod.price} Total: R\$ ${prod.price * prod.quantity}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ))
        ],
      ),
    );
  }
}
