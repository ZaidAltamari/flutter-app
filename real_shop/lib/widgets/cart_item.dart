import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem({
    @required this.id,
    @required this.productId,
    @required this.price,
    @required this.quantity,
    @required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to remove the item from the cart?'),
              actions: [
                TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    }),
                TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    }),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
        },
        child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
            child: Padding(
              padding: EdgeInsets.all(1),
              child: ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: EdgeInsets.all(1),
                    child: FittedBox(
                      child: Text('\$$price'),
                    ),
                  ),
                ),
                title: Text(title),
                subtitle: Text('Total price:  \$${price * quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      child: IconButton(
                        icon: Icon(Icons.add),
                        padding: EdgeInsets.all(0),
                        color: Colors.black,
                        iconSize: 14.0,
                        onPressed: () {
                          Provider.of<Cart>(context, listen: false)
                              .increaseQuantity(productId);
                        },
                      ),
                    ),
                    SizedBox(width: 1), // Add some spacing
                    Text('$quantity x'),
                    SizedBox(width: 1), // Add some spacing
                    Container(
                      width: 22,
                      child: IconButton(
                        icon: Icon(Icons.remove),
                        padding: EdgeInsets.all(0),
                        color: Colors.black,
                        iconSize: 14.0,
                        onPressed: () {
                          Provider.of<Cart>(context, listen: false)
                              .decreaseQuantity(productId);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
