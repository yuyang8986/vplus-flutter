import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/models/Order.dart';
import 'package:vplus/models/OrderItem.dart';
import 'package:vplus/models/OrderWithStore.dart';
import 'package:vplus/models/campaign.dart';
import 'package:vplus/providers/current_order_provider.dart';
import 'package:vplus/styles/color.dart';

class OrderHelper {
  static Color getOrderStatusColor(UserOrderStatus orderStatus) {
    Color color = preparingColor;
    switch (orderStatus) {
      case UserOrderStatus.Cancelled:
        color = cancelledColor;
        break;
      case UserOrderStatus.InProgress:
        color = inProgressColor;
        break;
      case UserOrderStatus.AwaitingConfirmation:
        color = awaitingConfirmationColor;
        break;
      case UserOrderStatus.Voided:
        color = voidedColor;
        break;
      case UserOrderStatus.Completed:
        color = completedColor;
        break;
      case UserOrderStatus.Started:
        color = preparingColor;
        break;
      case UserOrderStatus.Ready:
        color = readyColor;
        break;
      default:
        color = preparingColor;
        break;
    }
    return color;
  }

  static Color getDriverOrderStatusColor(UserOrderStatus orderStatus) {
    Color color = preparingColor;
    switch (orderStatus) {
      case UserOrderStatus.Ready:
        color = awaitingConfirmationColor;
        break;
      case UserOrderStatus.Delivering:
        color = preparingColor;
        break;
      case UserOrderStatus.Delivered:
        color = completedColor;
        break;
    }
    return color;
  }

  static String getOrderStatusText(UserOrderStatus orderStatus) {
    String orderStatusText = "";
    switch (orderStatus) {
      case UserOrderStatus.Cancelled:
        orderStatusText = "Cancelled";
        break;
      case UserOrderStatus.InProgress:
        orderStatusText = "InProgress";
        break;
      case UserOrderStatus.AwaitingConfirmation:
        orderStatusText = "Await Confirm";
        break;
      case UserOrderStatus.Voided:
        orderStatusText = "Voided";
        break;
      case UserOrderStatus.Completed:
        orderStatusText = "Completed";
        break;
      case UserOrderStatus.Started:
        orderStatusText = "Started";
        break;
      case UserOrderStatus.Ready:
        orderStatusText = "Ready";
        break;
      case UserOrderStatus.Delivered:
        orderStatusText = "Delivered";
        break;
      case UserOrderStatus.Delivering:
        orderStatusText = "Delivering";
        break;
    }
    return orderStatusText;
  }

  static String getDriverOrderStatusText(UserOrderStatus orderStatus) {
    String orderStatusText = "WaitPickUp";
    switch (orderStatus) {
      case UserOrderStatus.Ready:
        orderStatusText = "WaitPickUp";
        break;
      case UserOrderStatus.Delivering:
        orderStatusText = "Delivering";
        break;
      case UserOrderStatus.Delivered:
        orderStatusText = "Delivered";
        break;
    }
    return orderStatusText;
  }

  static Color getOrderItemStatusColor(ItemStatus itemStatus) {
    Color color = preparingColor;
    switch (itemStatus) {
      case ItemStatus.AwaitingConfirmation:
        color = awaitingConfirmationColor;
        break;
      case ItemStatus.Ready:
        color = readyColor;
        break;
      case ItemStatus.Preparing:
        color = preparingColor;
        break;
      case ItemStatus.Served:
        color = servedColor;
        break;
      case ItemStatus.Cancelled:
        color = cancelledColor;
        break;
      case ItemStatus.Returned:
        color = returnedColor;
        break;
      default:
        color = preparingColor;
        break;
    }
    return color;
  }

  static String getOrderItemStatusText(ItemStatus itemStatus) {
    String orderStatusText = "";
    switch (itemStatus) {
      case ItemStatus.Cancelled:
        orderStatusText = "Cancelled";
        break;
      case ItemStatus.Ready:
        orderStatusText = "Ready";
        break;
      case ItemStatus.AwaitingConfirmation:
        orderStatusText = "Await Confirm";
        break;
      case ItemStatus.Voided:
        orderStatusText = "Voided";
        break;
      case ItemStatus.Served:
        orderStatusText = "Served";
        break;
      case ItemStatus.Preparing:
        orderStatusText = "Preparing";
        break;
      case ItemStatus.Returned:
        orderStatusText = "Returned";
        break;
    }
    return orderStatusText;
  }

  static Order applyCampaignDiscountToOrder(
      BuildContext context, Order order, Campaign campaign) {
    // calculate the discount for campaign orders
    double discount;
    order.totalAmount =
        Provider.of<CurrentOrderProvider>(context, listen: false)
            .calculateOrderOrignalPrice(order);
    switch (campaign.campaignType) {
      case CampaignType.Percentage:
        discount = order.totalAmount * (campaign.percentage * 0.01);
        break;
      case CampaignType.Discount:
        if (order.totalAmount < campaign.discountTarget) {
          discount = 0;
        } else {
          discount = campaign.discountOff;
        }
        break;
    }
    order.totalAmount -= discount;
    order.discount = discount;
    return order;
  }

  static List<OrderWithStore> addOrUpdateOrderWithStore(
      List<OrderWithStore> orderList, OrderWithStore order) {
    if (!orderList.contains(order))
      orderList.add(order);
    else {
      orderList[orderList.indexWhere(
          (os) => os.order.userOrderId == order.order.userOrderId)] = order;
    }
    return orderList;
  }

  static double calculateDeliveryFee(double customerToStoreDistance) {
    // calculate the delivery fee based on the customer to store distance
    // distance measures in meters
    double deliveryFee;
    if (customerToStoreDistance <= 2000) {
      deliveryFee = 2.99;
    } else if (customerToStoreDistance <= 3000) {
      deliveryFee = 3.99;
    } else if (customerToStoreDistance <= 4000) {
      deliveryFee = 4.99;
    } else if (customerToStoreDistance <= 5000) {
      deliveryFee = 5.99;
    } else {
      /// user should not be able to place order greater than 5km, please check
      /// the STORE_ORDER_DISTANCE in config folder to double check that this
      /// statement is not allowed.
      deliveryFee = 5.99;
    }
    return deliveryFee;
  }

  static Order tranformOrderToDeliveryOrder(
      Order userOrder, double deliveryFee) {
    /// If user submitted a delivery order, need to change the order type and
    /// process the delivery fee before submit order.
    /// This method is used to transform a pickup order to delivery order.
    userOrder.orderType = OrderType.Delivery;
    userOrder.deliveryFee = deliveryFee;
    userOrder.totalAmount += deliveryFee;
    return userOrder;
  }
}
