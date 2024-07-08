extends Node

signal unlock_new_skin

var google_payment = null
var new_skin_sku = "new_player_skin" # need to be matched on google console


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
		google_payment.startConnection()
	else:
		MyUtility.add_log_msg("Android IAP support is not available")	
	

func purchase_skin():
	if google_payment:
		var response = google_payment.purchase(new_skin_sku)
		MyUtility.add_log_msg("Purchased attempted, response: " + str(response.status))
		
		if response.status != OK:
			MyUtility.add_log_msg("Error purchasing skin!.")

func _on_connected():
	MyUtility.add_log_msg("Connected")
	google_payment.querySkuDetails([new_skin_sku], "inapp")

func _on_connect_error(response_id, debug_msg):
	MyUtility.add_log_msg("Error occured, response id: " + str(response_id) + ". Debug msg: " + debug_msg)

func _on_disconnected():
	MyUtility.add_log_msg("Disconnected from googlepayment")

func _on_sku_details_query_completed(skus):
	MyUtility.add_log_msg("sku detail query comoleted")
	
	for sku in skus:
		MyUtility.add_log_msg("SKUs")
		MyUtility.add_to_group(str(sku))


func _on_sku_details_query_error(response_id, error_message, skus):
	MyUtility.add_log_msg("Sku query error , response id: " + str(response_id) + " ,message: " + str(error_message) + ", skus: " + str(skus) )

func _on_purchases_updated(purchases):
	if purchases.size() > 0:
		var purchase = purchases[0]
		var purchase_sku = purchase["skus"][0]
	
func _on_purchase_error(response_id, error_message):
	MyUtility.add_log_msg("Purchase error, response id: " + str(response_id) + ". Debug msg: " + error_message)
