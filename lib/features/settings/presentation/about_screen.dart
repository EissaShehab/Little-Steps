import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LittleSteps aims to digitize and simplify the management of your child\'s health journey, including growth tracking, vaccinations, and health tips. It transforms user inputs into organized health records based on predefined templates for each health category.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Contact Information:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'eissashehab846@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Website: github/EissaShehab',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'NCC: 0786046084',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}