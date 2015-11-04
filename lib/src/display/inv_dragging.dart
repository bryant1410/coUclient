part of couclient;

class InvDragging {
	/// Overrides (if this list is not empty, inventory dragging will not work)
	/// This allows any external function to disable dragging for its own reason, and not interfere with others
	static List<String> _disablers = [];
	/// Track inventory updating
	static Service _refresh;
	/// Draggable items
	static Draggable _draggables;
	/// Drop targets
	static Dropzone _dropzones;
	/// State tracking
	static Element _currentlyDisplaced, _origBox;

	/**
	 * Map used to store *how* the item was moved.
	 * Keys:
	 * - General:
	 * - - item_number: element: span element containing the count label
	 * - - bag_btn: element: the toggle button for containers
	 * - On Pickup:
	 * - - fromBag: boolean: whether the item used to be in a bag
	 * - - fromBagIndex: int: which slot the toBag is in  (only set if fromBag is true)
	 * - - fromIndex: int: which slot the item used to be in
	 * - On Drop:
	 * - - toBag: boolean: whether the item is going into a bag
	 * - - toBagIndex: int: which slot the toBag is in (only set if toBag is true)
	 * - - toIndex: int: which slot the item is going to
	 */
	static Map<String, dynamic> _move = {};

	/// Add an override
	static bool disable(String reason) {
		if (_disablers.contains(reason)) {
			// Already disabled for that reason
			return false;
		} else {
			// Disable for that reason and refresh
			_disablers.add(reason);
			init();
			return true;
		}
	}

	/// Remove an override
	static bool enable(String reason) {
		if (_disablers.contains(reason)) {
			// Enable for that reason and refresh
			_disablers.remove(reason);
			init();
			return true;
		} else {
			// No disabler for that reason
			return false;
		}
	}

	/// Checks if the specified slot is empty
	static bool slotIsEmpty({int index, Element box, int bagWindow}) {
		if (index != null) {
			if (bagWindow == null) {
				box = querySelectorAll("#inventory .box").toList()[index];
			} else {
				box = querySelectorAll("#bagWindow$bagWindow").toList()[index];
			}
		}

		return (box.children.length == 0);
	}

	/// Whether to force horizontal-only movement
	static bool get _horizontalLock {
		// Allow dragging up into bag windows
		if (BagWindow.isOpen) {
			return false;
		}

		// Allow disabler to control movement
		if (_disablers.length > 0) {
			return false;
		}

		// No special conditions
		return true;
	}

	/// Set up event listeners based on the current inventory
	static void init() {
		if (_refresh == null) {
			_refresh = new Service(["inventoryUpdated"], (_) => init());
		}
		// Remove old data
		if (_draggables != null) {
			_draggables.destroy();
		}
		if (_dropzones != null) {
			_dropzones.destroy();
		}

		if (_disablers.length == 0) {
			// Set up draggable elements
			_draggables = new Draggable(
				// List of item elements in boxes
				querySelectorAll('.inventoryItem'),
				// Display the item on the cursor
				avatarHandler: new CustomAvatarHandler(),
				// If a bag is open, allow free dragging.
				// If not, only allow horizontal dragging across the inventory bar
				horizontalOnly: _horizontalLock,
				// Disable item interaction while dragging it
				draggingClass: "item-flying"
			)
				..onDragStart.listen((DraggableEvent e) => handlePickup(e));

			// Set up acceptor slots
			_dropzones = new Dropzone(querySelectorAll("#inventory .box"))
				..onDrop.listen((DropzoneEvent e) => handleDrop(e));
		}
	}

	/// Runs when an item is picked up (drag start)
	static void handlePickup(DraggableEvent e) {
		_origBox = e.draggableElement.parent;
		e.draggableElement.dataset["original-slot-num"] = _origBox.dataset["slot-num"];

		_move = {};

		if (querySelector("#windowHolder").contains(_origBox)) {
			_move['fromIndex'] = int.parse(_origBox.parent.parent.dataset["source-bag"]);
			_move["fromBagIndex"] = int.parse(_origBox.dataset["slot-num"]);
		} else {
			_move['fromIndex'] = int.parse(_origBox.dataset["slot-num"]);
		}
	}

	/// Runs when an item is dropped (drop)
	static void handleDrop(DropzoneEvent e) {
		if (querySelector("#windowHolder").contains(e.dropzoneElement)) {
			_move["toIndex"] = int.parse(e.dropzoneElement.parent.parent.dataset["source-bag"]);
			_move["toBagIndex"] = int.parse(e.dropzoneElement.dataset["slot-num"]);
		} else {
			_move["toIndex"] = int.parse(e.dropzoneElement.dataset["slot-num"]);
		}

		sendAction("moveItem", "global_action_monster", _move);
	}
}

class BagFilterAcceptor extends Acceptor {
	BagFilterAcceptor(this.allowedItemTypes);

	List<String> allowedItemTypes;

	@override
	bool accepts(Element itemE, int draggable_id, Element box) {
		ItemDef item = decode(itemE.attributes['itemmap'],type:ItemDef);
		if (allowedItemTypes.length == 0) {
			// Those that accept nothing learn to accept everything (except other containers)
			return !item.isContainer;
		} else {
			// Those that are at least somewhat accepting are fine, though
			return allowedItemTypes.contains(item.itemType);
		}
	}
}