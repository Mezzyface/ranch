@tool
class_name TimeData extends Resource

@export var week: int = 1
@export var month: int = 1
@export var year: int = 1
@export var total_weeks: int = 0
@export var last_save_week: int = 0

func is_valid() -> bool:
	return week > 0 and month > 0 and year > 0 and total_weeks >= 0

func to_dict() -> Dictionary:
	return {
		"week": week,
		"month": month,
		"year": year,
		"total_weeks": total_weeks,
		"last_save_week": last_save_week
	}

func from_dict(data: Dictionary) -> void:
	if not data.has("week") or not data.has("month") or not data.has("year"):
		push_error("TimeData.from_dict: Missing required time data fields")
		return

	week = data.get("week", 1)
	month = data.get("month", 1)
	year = data.get("year", 1)
	total_weeks = data.get("total_weeks", 0)
	last_save_week = data.get("last_save_week", 0)

	if not is_valid():
		push_error("TimeData.from_dict: Invalid time data after loading")

func get_formatted_date() -> String:
	return "Year %d, Month %d, Week %d" % [year, month, week]