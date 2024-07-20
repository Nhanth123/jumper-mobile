extends Node

signal unlock_new_skin

var google_payment = null
var new_skin_sku = "new_player_skin" # need to be matched on google console
var new_skin_token = ""

var apple_payment = null
var apple_product_id = "player_new_skin" # need to be matched on apple store

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		google_payment = Engine.get_singleton("GodotGooglePlayBilling")
		MyUtility.add_log_msg("Android IAP support is enabled")
		
		google_payment.connected.connect(_on_connected)
		google_payment.connect_error.connect(_on_connect_error)
		google_payment.disconnected.connect(_on_disconnected)
		google_payment.sku_details_query_completed.connect(_on_sku_details_query_completed)
		
		google_payment.sku_details_query_error.connect(_on_sku_details_query_error)
		
		google_payment.purchases_updated.connect(_on_purchases_updated)
		google_payment.purchase_error.connect(_on_purchase_error)
		
		google_payment.purchase_acknowledged.connect(_on_purchase_acknowledged)
		google_payment.purchase_acknowledgement_error.connect(_on_purchase_acknowledgement_error)
		google_payment.query_purchases_response.connect(_on_query_purchases_response)
		
		google_payment.purchase_consumed.connect(_on_purchase_consumed)
		google_payment.purchase_consumption_error.connect(_on_purchase_consumption_error)

		google_payment.startConnection()
	else:
		MyUtility.add_log_msg("Android IAP support is not available")
	
	if Engine.has_singleton("InAppStore"):
		apple_payment = Engine.get_singleton("InAppStore")
		MyUtility.add_log_msg("iOS IAP support is available")
		
		var result = apple_payment.request_product_info({"product_ids": [apple_product_id]})
		if result == OK:
			MyUtility.add_log_msg("iOS IAP support is not available")
			apple_payment.set_auto_finish_transaction(true)
			
			var timer = Timer.new()
			timer.wait_time = 1
			timer.timeout.connect(check_events)
			add_child(timer)
			timer.start()
		else:
			MyUtility.add_log_msg("Failed to request product info")
	else:
		MyUtility.add_log_msg("iOS IAP support is not available")
		
func purchase_skin():
	if google_payment:
		var response = google_payment.purchase(new_skin_sku)
		MyUtility.add_log_msg("Purchased attempted, response: " + str(response.status))
		
		if response.status != OK:
			MyUtility.add_log_msg("Error purchasing skin!.")
	elif apple_payment:
		var result = apple_payment.purchase({"product_id": apple_product_id})
		if result == OK:
			MyUtility.add_log_msg("Error result OK!")
		else:
			MyUtility.add_log_msg("Purchase failed!")
	
func reset_purchases():
	if google_payment:
		if !new_skin_token.is_empty():
			google_payment.consumePurchase(new_skin_token)

func restore_purchases():
	if apple_payment:
		var result = apple_payment.restore_purchases()
		if result == OK:
			MyUtility.add_log_msg("Restore purchases call is successful")
		else:
			MyUtility.add_log_msg("Restore purchases call failed")
	elif google_payment:
		google_payment.queryPurchases("inapp")

# Using for iOS Purchase
func check_events():
	while apple_payment.get_pending_event_count() > 0:
		var event = apple_payment.pop_pending_event()
		if event.result == "ok":
			match event.type:
				"product_info":
					MyUtility.add_log_msg(str(event))
					var result = apple_payment.restore_purchases()
					
					if result == OK:
						MyUtility.add_log_msg("Restore purchases call is successful")
					else:
						MyUtility.add_log_msg("Restore purchases call failed")
				"purchase":
					if event.product_id == apple_product_id:
						unlock_new_skin.emit()
						MyUtility.add_log_msg("Purchase the skin IAP , unlocking it !")
				"restore":
					MyUtility.add_log_msg("Restore transaction ID: " + str(event.transaction_id) + " ProductID: " + str(event.product_id) )
					if event.product_id == apple_product_id:
						unlock_new_skin.emit()
						MyUtility.add_log_msg("Restored previously purchased skin !")
					
func _on_connected():
	MyUtility.add_log_msg("Connected to googlepayment console")
	google_payment.querySkuDetails([new_skin_sku], "inapp")

func _on_connect_error(response_id, debug_msg):
	MyUtility.add_log_msg("Error occured, response id: " + str(response_id) + ". Debug msg: " + debug_msg)

func _on_disconnected():
	MyUtility.add_log_msg("Disconnected from googlepayment")

func _on_sku_details_query_completed(skus):
	MyUtility.add_log_msg("Sku detail query completed")
	
	for sku in skus:
		MyUtility.add_log_msg("SKUs:")
		MyUtility.add_log_msg(str(sku))
	
	google_payment.queryPurchases("inapp")


func _on_sku_details_query_error(response_id, error_message, skus):
	MyUtility.add_log_msg("Sku query error , response id: " + str(response_id) + " ,message: " + str(error_message) + ", skus: " + str(skus) )

func _on_purchases_updated(purchases):
	if purchases.size() > 0:
		var purchase = purchases[0]
		var purchase_sku = purchase["skus"][0]
		MyUtility.add_log_msg("Purchased item with sku: " + purchase_sku)
		if purchase_sku == new_skin_sku:
			new_skin_token = purchase.purchase_token
			google_payment.acknowledgePurchase(purchase.purchase_token)
	
func _on_purchase_error(response_id, error_message):
	MyUtility.add_log_msg("Purchase error, response id: " + str(response_id) + ". Debug msg: " + error_message)


func _on_purchase_acknowledged(purchase_token):
	MyUtility.add_log_msg("Purchase acknowledged successfully!")
	
	if !new_skin_token.is_empty():
		if new_skin_token == purchase_token:
			MyUtility.add_log_msg("Unlock new skin!")
			unlock_new_skin.emit()
	

func _on_purchase_acknowledgement_error(response_id, error_message, purchase_token):
	MyUtility.add_log_msg("Purchase acknowledgement error , response id: " + str(response_id) + " ,message: " + str(error_message) + ", token: " + str(purchase_token) )

func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		MyUtility.add_log_msg("Query purchases was successful")
		var purchases = query_result.purchases
		var purchase = purchases[0]
		var purchase_sku = purchase["skus"][0]
		if new_skin_sku == purchase_sku:
			new_skin_token = purchase.purchase_token
			if !purchase.is_acknowledged:
				google_payment.acknowledgePurchase(purchase.purchase_token)
			else:
				unlock_new_skin.emit()
				MyUtility.add_log_msg("Unlock because already purchased previously")
	else:
		MyUtility.add_log_msg("Query purchases failed")


func _on_purchase_consumed(purchase_token):
	MyUtility.add_log_msg("Purchase consumed successfully!. " + str(purchase_token))
	

func _on_purchase_consumption_error(response_id, error_message, purchase_token):
	MyUtility.add_log_msg("Purchase consumption error , response id: " + str(response_id) + " ,message: " + str(error_message) + ", token: " + str(purchase_token) )

