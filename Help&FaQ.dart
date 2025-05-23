import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {

  final List<FAQItem> _faqs = [
    FAQItem(
        Icons.energy_savings_leaf_rounded,
        'How accurate is the energy consumption data?',
        'Our app provides estimates based on your input and device integrations. For precise measurements, we recommend using smart meters or verified energy monitoring devices.'
    ),
    FAQItem(
        Icons.show_chart,
        'Can I track multiple apartments?',
        'Yes, you can add multiple locations in the app settings. Each location will have its own dashboard and analytics.'
    ),
    FAQItem(
        Icons.security,
        'Is my data secure?',
        'Absolutely. We use industry-standard encryption and never share your personal data without your explicit permission.'
    ),
    FAQItem(Icons.update,
        'How often is the data updated?',
        'Data updates depend on your device connections. Smart devices typically update every 15-30 minutes, while manual entries update immediately.'
    ),
    FAQItem(
        Icons.file_download,
        'Can I export my data?',
        'Yes, you can export your energy data in various formats (CSV, JSON, PDF) from the Privacy & Data section in settings.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        backgroundColor: Colors.blue,
        title: const Text('Help & FaQs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
      ),
      body: ListView(
     // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        Container(
          height: 700,
          child:ListView.builder(
            itemCount: _faqs.length,
            itemBuilder: (context, index) {
              return _buildFAQItem(_faqs[index]);
            },
          ) ,
        ),

        ],
      ),
    );
  }


  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ExpansionTile(
        minTileHeight: 80,
        leading: Icon(faq.icon, color: Colors.blue.shade600,size: 27,),
        backgroundColor: Colors.blueGrey.shade50,
        title: Text(faq.question, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(faq.answer),
          ),
        ],
      ),
    );
  }

}

class FAQItem {
  final IconData icon;
  final String question;
  final String answer;

  FAQItem(this.icon,this.question,this.answer);
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
            fontSize: 20
        ),
      ),
    );
  }
}



