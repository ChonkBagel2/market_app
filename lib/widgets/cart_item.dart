import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    this.id,
    this.productId,
    this.title,
    this.price,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        margin: const EdgeInsets.all(15),
        color: Colors.red.shade400,
        padding: const EdgeInsets.all(10),
        child: Icon(Icons.delete),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            elevation: 5,
            title: Text('Are you sure? '),
            content: Text(
                'The selected item will be removed from the Cart. Proceed? '),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text('Yes'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: Text('No'),
              )
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.all(15),
        child: ListTile(
          leading: CircleAvatar(
            child: FittedBox(
              child: Text('\$${price}'),
            ),
          ),
          title: Text('$title'),
          subtitle: Text('Total : ${(price * quantity)} '),
          trailing: Text('Quantitiy : $quantity x'),
        ),
      ),
    );
  }
}
