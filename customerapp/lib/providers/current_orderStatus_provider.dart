// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:vplus/helper/apiHelper.dart';
// import 'package:vplus/models/ExtraOrder.dart';
// import 'package:vplus/models/Order.dart';
// import 'package:vplus/models/OrderItem.dart';

// enum OrderStatusPageType {
//   tableAddOrder,
//   tableViewOrder,
//   orderListPortrait,
//   orderListLandscape,
//   user,
//   none
// }

// class Current_OrderStatus_Provider with ChangeNotifier {
//   Order order;
//   bool isActiveOrder = true;
//   bool hasExtraOrder;
//   //bool displayAppBar = true;
//   bool isResetByOtherDevice = false;
//   //bool allowModification = true;
//   // String extraOrderNotes="";
//   OrderStatusPageType _orderStatusPageType;

//   bool paymentSuccessful = false;
//   OrderPaymentStatus paymentStatus = OrderPaymentStatus.AwaitingPayment;

//   // Current_OrderStatus_Provider({
//   //   this.order,
//   //   this.isActiveOrder = true,
//   //   this.hasExtraOrder,
//   //   // this.extraOrderNotes,
//   // });

//   // void initOrderUserItems(
//   //     BuildContext context, Order order, bool isActiveOrder) {
//   //   determineOrderStatus(order, isActiveOrder);
//   // }

//   bool checkAnOrderBeenPaid(Order order) {
//     if (order.isPaid ||
//         (order.paymentSuccessful != null && order.paymentSuccessful)) {
//       if (order.userExtraOrders != null && order.userExtraOrders.length != 0) {
//         for (ExtraOrder extraOrder in order.userExtraOrders) {
//           if (!extraOrder.isPaid) {
//             return false;
//           }
//         }
//         order.paymentStatus = OrderPaymentStatus.Paid;
//         return true;
//       }
//       order.paymentStatus = OrderPaymentStatus.Paid;
//       return true;
//     }
//     return false;
//   }

//   double calculateOutstandingPayment(Order order) {
//     double result = 0;
//     if (!order.isPaid) {
//       order.userItems.forEach((element) {
//         if (element.itemStatus != ItemStatus.Cancelled &&
//             element.itemStatus != ItemStatus.Voided &&
//             element.itemStatus != ItemStatus.Returned) result += element.price;
//       });
//     }
//     if (order.userExtraOrders != null && order.userExtraOrders.length != 0) {
//       order.userExtraOrders.forEach((element) {
//         if (element.userItems != null && element.userItems.length != 0) {
//           if (!element.isPaid)
//             element.userItems.forEach((userItem) {
//               if (userItem.itemStatus != ItemStatus.Cancelled &&
//                   userItem.itemStatus != ItemStatus.Voided &&
//                   userItem.itemStatus != ItemStatus.Returned)
//                 result += userItem.price;
//             });
//         }
//       });
//     }
//     double mod = pow(10.0, 2);
//     result = ((result * mod).round().toDouble() / mod);
//     return result;
//   }

//   void determineOrderStatus(Order order, bool isActiveOrder,
//       {bool updateView = true}) {
//     bool itemStillWaiting = false;
//     bool itemStillPreparing = false;
//     bool itemBeenServed = false;
//     int cancelledItem = 0;
//     int returnedItem = 0;

//     bool servedAll = false;
//     int servedItem = 0;

//     List<OrderItem> _orderItems = getOrderItemList(order);

//     order.paymentSuccessful = checkAnOrderBeenPaid(order);

//     for (int i = 0; i < _orderItems.length; i++) {
//       switch (_orderItems[i].itemStatus) {
//         case ItemStatus.AwaitingConfirmation:
//           itemStillWaiting = true;
//           break;
//         case ItemStatus.Preparing:
//           itemStillPreparing = true;
//           break;
//         case ItemStatus.Cancelled:
//           cancelledItem++;
//           break;
//         case ItemStatus.Returned:
//           returnedItem++;
//           break;
//         case ItemStatus.Served:
//           itemBeenServed = true;
//           servedItem++;
//           if ((servedItem + cancelledItem + returnedItem) ==
//               _orderItems.length) {
//             servedAll = true;
//           }
//           break;
//         case ItemStatus.Voided:
//           // TODO: Handle this case.

//           break;
//       }
//     }

//     if (!isActiveOrder &&
//         servedAll &&
//         !itemStillWaiting &&
//         // !order.isAdminReset &&
//         order.paymentSuccessful) {
//       order.userOrderStatus = UserOrderStatus.Completed;
//       if (order.paymentSuccessful)
//         order.paymentStatus = OrderPaymentStatus.Paid;
//       return;
//     }

//     if (itemStillWaiting) {
//       order.userOrderStatus = UserOrderStatus.AwaitingConfirmation;

//       if (!order.paymentSuccessful)
//         order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
//       return;
//     }
//     if (itemStillPreparing && !itemStillWaiting) {
//       order.userOrderStatus = UserOrderStatus.InProgress;

//       if (!order.paymentSuccessful)
//         order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
//       return;
//     }
//     if (itemBeenServed && !itemStillWaiting) {
//       order.userOrderStatus = UserOrderStatus.InProgress;

//       if (!order.paymentSuccessful)
//         order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
//       return;
//     }
//     if (cancelledItem == _orderItems.length && cancelledItem != 0) {
//       order.userOrderStatus = UserOrderStatus.Cancelled;
//       order.paymentStatus = OrderPaymentStatus.Cancelled;

//       // if (!order.paymentSuccessful)
//       //   order.paymentStatus = OrderPaymentStatus.Cancelled;
//       return;
//     }
//     if (returnedItem == _orderItems.length && returnedItem != 0) {
//       order.userOrderStatus = UserOrderStatus.Voided;
//       order.paymentStatus = OrderPaymentStatus.Voided;

//       // if (!order.paymentSuccessful)
//       // order.paymentStatus = OrderPaymentStatus.Voided;
//       return;
//     }
//     if (cancelledItem + returnedItem == _orderItems.length &&
//         cancelledItem != 0 &&
//         returnedItem != 0) {
//       order.userOrderStatus = UserOrderStatus.Voided;

//       if (!order.paymentSuccessful)
//         order.paymentStatus = OrderPaymentStatus.Voided;
//       return;
//     }

//     if (!isActiveOrder && order.paymentSuccessful && servedAll) {
//       order.userOrderStatus = UserOrderStatus.Completed;
//       order.paymentStatus = OrderPaymentStatus.Paid;
//       return;
//     }

//     if (!isActiveOrder && servedAll) {
//       order.userOrderStatus = UserOrderStatus.InProgress;
//       (order.paymentSuccessful)
//           ? order.paymentStatus = OrderPaymentStatus.Paid
//           : order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
//       return;
//     }

//     order.userOrderStatus = UserOrderStatus.Started;

//     if (!order.paymentSuccessful)
//       order.paymentStatus = OrderPaymentStatus.AwaitingPayment;
//     if (updateView) notifyListeners();
//   }

//   void currentOrderContainsExtraOrder() {
//     if (this.order != null &&
//         this.order.userExtraOrders == null &&
//         this.order.userExtraOrders.length == 0) {
//       this.hasExtraOrder = false;
//     } else {
//       this.hasExtraOrder = true;
//     }
//   }

//   void setOrder(BuildContext ctx, Order order, bool isActiveOrder) {
//     this.order = order;
//     if (this.order != null) currentOrderContainsExtraOrder();
//     this.isActiveOrder = isActiveOrder;
//     notifyListeners();
//   }

//   void setOrderAndNotNotify(BuildContext ctx, Order order, bool isActiveOrder) {
//     this.order = order;
//     if (this.order != null) currentOrderContainsExtraOrder();
//     this.isActiveOrder = isActiveOrder;
//   }

//   List<OrderItem> getOrderItemList(Order order) {
//     List<OrderItem> orderItems = [];
//     if (order.userItems != null && order.userItems.length != 0) {
//       order.userItems.forEach((element) {
//         orderItems.add(element);
//       });
//     }
//     if (order.userExtraOrders != null && order.userExtraOrders.length != 0) {
//       order.userExtraOrders.forEach((extraOrders) {
//         if (extraOrders.userItems != null &&
//             extraOrders.userItems.length != 0) {
//           extraOrders.userItems.forEach((element) {
//             orderItems.add(element);
//           });
//         }
//       });
//     }
//     return orderItems;
//   }

//   Future<void> callAPI(List<int> orderItemsId, String url, BuildContext context,
//       ItemStatus itemStatus) async {
//     var helper = Helper();
//     var response = await helper.putData(url, orderItemsId,
//         context: context, hasAuth: true);
//     if (response.isSuccess) {
//       print('Successful');
//     }
//   }

//   // Future<void> initUserItems(
//   //     BuildContext context, bool isActiveOrder, Order order) async {
//   //   // this.order.userItems = data.userItems;
//   //   // this.order.userExtraOrders = data.userExtraOrders;
//   //   // this.order.isPaid = data.isPaid;
//   //   // // this.order.isAdminReset = data.isAdminReset;
//   //   determineOrderStatus(order, isActiveOrder);

//   //   ///}
//   // }

//   Future<void> hardResetOrder(List<Order> orders, BuildContext context) async {
//     List<int> ordersId = [];

//     orders.forEach((element) {
//       element.isAdminReset = true;
//       ordersId.add(element.userOrderId);
//     });
//     var helper = Helper();
//     var response = await helper.putData(
//         'api/Menu/userOrders/resetTableAdmin', ordersId,
//         context: context, hasAuth: true);
//     if (response.isSuccess) {
//       print('Hard Reset Successful');
//     }
//   }

//   void setIsActive(bool isActiveOrder) {
//     this.isActiveOrder = isActiveOrder;
//     notifyListeners();
//   }

//   void setPaymentSuccessful(BuildContext context, bool paymentSuccessful) {
//     this.order.paymentSuccessful = paymentSuccessful;
//     this.paymentSuccessful = paymentSuccessful;
//     // Provider.of<OrderListProvider>(context,listen: false).updateActiveOrder(this.order);
//     notifyListeners();
//   }

//   void setPaymentStatus(
//       BuildContext context, OrderPaymentStatus orderPaymentStatus) {
//     this.paymentStatus = orderPaymentStatus;
//     this.order.paymentStatus = orderPaymentStatus;
//     // Provider.of<OrderListProvider>(context,listen: false).updateActiveOrder(this.order);
//     notifyListeners();
//   }

//   bool getisActive() {
//     return this.isActiveOrder;
//   }

//   Order getOrder() {
//     return this.order;
//   }

//   bool getHasExtraOrder() {
//     return this.hasExtraOrder;
//   }

//   void setIsResetByOtherDevice(bool reset) {
//     this.isResetByOtherDevice = reset;
//     // notifyListeners();
//   }

//   bool getIsResetByOtherDevice() {
//     return this.isResetByOtherDevice;
//   }

//   void setOrderStatusType(OrderStatusPageType orderStatusPageType) {
//     _orderStatusPageType = orderStatusPageType;
//   }

//   OrderStatusPageType get getOrderStatusType => _orderStatusPageType;

//   bool get isAllowUpdateOrder =>
//       _orderStatusPageType != OrderStatusPageType.tableAddOrder;

//   bool get showAppBar =>
//       getOrderStatusType == OrderStatusPageType.tableViewOrder ||
//       getOrderStatusType == OrderStatusPageType.orderListPortrait;

//   Future<void> updateCurrentOrderFromAPI(BuildContext orderStatusPageContext,
//       String userOrderId, bool isActiveOrder) async {
//     var helper = Helper();
//     var response = await helper.getData('api/Menu/userOrders/${userOrderId}',
//         context: orderStatusPageContext);
//     if (response.isSuccess && response.data != null) {
//       Order order = Order.fromJson(response.data);
//       if (orderStatusPageContext != null) {
//         determineOrderStatus(order, isActiveOrder, updateView: false);
//         setOrder(orderStatusPageContext, order, isActiveOrder);
//       }
//     } else {
//       print('Get Data Failed');
//     }
//   }
// }
