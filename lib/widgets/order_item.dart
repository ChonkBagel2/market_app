import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart';

import 'dart:math';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  OrderItemWidget(this.order);

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? min(widget.order.products.length * 35.0 + 120.0, 200) : 120,
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: Text(
                '\$${widget.order.amount.toStringAsFixed(2)} ',
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.datetime),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: _expanded
                    ? const Icon(Icons.expand_less)
                    : const Icon(Icons.expand_more),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 20.0, 100)
                  : 0,
              padding: const EdgeInsets.all(10),
              child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          children: [
                            Text(prod.title + '  '),
                            Text('x ${prod.quantity} '),
                            const Spacer(),
                            Text('\$ ${prod.price} '),
                          ],
                        ),
                      )
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
