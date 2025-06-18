import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/checkout/checkout.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDurationIndex = 0;
  int selectedWorkerCount = 1;
  bool isPetFriendly = false;
  TextEditingController specialInstructionsController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTimeSlot;

  final List<String> allTimeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
  ];

  final List<String> bookedSlots = ['', ''];

  final List<Map<String, dynamic>> durations = [
    {'label': '1 Hour', 'price': 60},
    {'label': '1.5 Hours', 'price': 85},
    {'label': '2 Hours', 'price': 110},
    {'label': '2.5 Hours', 'price': 135},
    {'label': '3.5 Hours', 'price': 160},
    {'label': '4 Hours', 'price': 180},
  ];

  @override
  Widget build(BuildContext context) {
    int basePrice = durations[selectedDurationIndex]['price'];
    int totalPrice = (isPetFriendly ? basePrice + 25 : basePrice) * selectedWorkerCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context),
              const SizedBox(height: 8),
              const Text("Hourly Cleaning", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Book cleaners on hourly basis based on your requirement."),
              const SizedBox(height: 20),
              const Text("Select Duration", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...List.generate(durations.length, (index) {
                bool isSelected = selectedDurationIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedDurationIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? Colors.orange : Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(durations[index]['label']),
                        Text("AED ${durations[index]['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text("Select Number of Workers", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(4, (index) {
                  int worker = index + 1;
                  bool isSelected = selectedWorkerCount == worker;
                  return ChoiceChip(
                    label: Text("$worker Needed"),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedWorkerCount = worker),
                    selectedColor: Colors.orange[200],
                  );
                }),
              ),
              const SizedBox(height: 20),
              _buildPetOption(),
              const SizedBox(height: 20),
              _buildSpecialInstructions(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildTimeSlotSelector(),
              const SizedBox(height: 20),
              const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildBookingSummary(durations[selectedDurationIndex]['label'], totalPrice),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedDate != null && selectedTimeSlot != null)
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Checkout(
                                selectedDate: selectedDate!,
                                selectedTimeSlot: selectedTimeSlot!,
                                sizeLabel: durations[selectedDurationIndex]['label'],
                                price: totalPrice,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text("Go to Checkout", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.1, 8, 0.1, 8),
      child: Row(
        children: [
          Image.asset('assets/images/houzylogoimage.png', height: 40),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              
            },
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'No email',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/account');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pet-Friendly Service", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Extra care around pets, pet hair removal, and pet-safe products"),
            ],
          ),
        ),
        Row(
          children: [
            const Text("+AED 25", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Switch(value: isPetFriendly, onChanged: (val) => setState(() => isPetFriendly = val)),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Special Instructions", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: specialInstructionsController,
          decoration: InputDecoration(
            hintText: "e.g., Please focus on the kitchen...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a Date", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey[100],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null ? DateFormat('MMM d, yyyy').format(selectedDate!) : 'Tap to select a date',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a Time Slot", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allTimeSlots.map((slot) {
            bool isBooked = bookedSlots.contains(slot);
            bool isSelected = selectedTimeSlot == slot;
            return GestureDetector(
              onTap: isBooked ? null : () => setState(() => selectedTimeSlot = slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isBooked ? Colors.grey[300] : isSelected ? Colors.orange[100] : Colors.white,
                  border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isBooked ? Colors.grey : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingSummary(String duration, int price) {
    final currencyFormat = NumberFormat.currency(locale: 'en_AE', symbol: 'AED ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _summaryRow("Service", "Hourly Cleaning"),
          _summaryRow("Duration", duration),
          _summaryRow("Workers", "$selectedWorkerCount Needed"),
          if (selectedDate != null) _summaryRow("Date", DateFormat('MMM d, yyyy').format(selectedDate!)),
          if (selectedTimeSlot != null) _summaryRow("Time", selectedTimeSlot!),
          const Divider(),
          _summaryRow("Total", currencyFormat.format(price), isBold: true),
          const SizedBox(height: 6),
          const Text("One-time payment", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
  }

