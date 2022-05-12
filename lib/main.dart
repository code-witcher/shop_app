import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_items_screen.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/screens/manage_user_products.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';

import './providers/cart_provider.dart';
import './providers/product_provider.dart';
import './screens/product_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (ctx) => ProductProvider(),
          update: (ctx, auth, prevProd) => ProductProvider()
            ..update(
              auth.token,
              auth.userId,
              prevProd == null ? [] : prevProd.items,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (ctx) => Cart(),
          update: (ctx, auth, prevCart) => Cart()
            ..update(
              auth.token,
              prevCart == null ? {} : prevCart.items,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, OrderProvider>(
          create: (ctx) => OrderProvider(),
          update: (ctx, auth, prevOrder) => OrderProvider()
            ..update(
              auth.token,
              auth.userId,
              prevOrder == null ? [] : prevOrder.orders,
            ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop App',
          theme: ThemeData(
              primarySwatch: Colors.red,
              accentColor: Colors.cyan,
              canvasColor: const Color.fromRGBO(255, 255, 255, 1),
              fontFamily: 'Lato'),
          home: auth.isAuth
              ? const ProductOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authDataSnap) =>
                      authDataSnap.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailsScreen.routeName: (ctx) =>
                const ProductDetailsScreen(),
            CartItemScreen.routeName: (ctx) => const CartItemScreen(),
            OrderScreen.routeName: (ctx) => const OrderScreen(),
            UserProducts.routeName: (ctx) => const UserProducts(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
