#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from lambda_function import mask_sensitive_data

def test_masking():
    
    print("🧪 Testing masking functionality...")
    print("=" * 50)
    
    # Test data based on the requirements
    test_cases = [
        {
            'type': 'Names',
            'original': 'Crystal White',
            'expected': 'Crystal *****'
        },
        {
            'type': 'Emails', 
            'original': 'davisjesus@example.org',
            'expected': 'd*********@example.org'
        },
        {
            'type': 'Phone Numbers',
            'original': '010-7658-5153',
            'expected': '010-7658-****'
        },
        {
            'type': 'SSNs',
            'original': '887-07-7325', 
            'expected': '887-07-****'
        },
        {
            'type': 'Credit Cards',
            'original': '4468-6779-7028-4776',
            'expected': '4468-6779-7028-****'
        },
        {
            'type': 'UUIDs',
            'original': '665ef2db-cd63-4086-81e9-661ccaf8dd20',
            'expected': '665ef2db-cd63-4086-81e9-************'
        }
    ]
    
    all_passed = True
    
    for test_case in test_cases:
        original = test_case['original']
        expected = test_case['expected']
        data_type = test_case['type']
        
        # Test the masking
        result = mask_sensitive_data(original)
        
        # Check if the result matches expected
        if result == expected:
            print(f"✅ {data_type}: {original} -> {result}")
        else:
            print(f"❌ {data_type}: {original} -> {result} (expected: {expected})")
            all_passed = False
    
    print("=" * 50)
    
    if all_passed:
        print("🎉 All tests passed! Masking functionality is working correctly.")
    else:
        print("⚠️  Some tests failed. Please check the masking logic.")
    
    return all_passed

def test_mixed_content():
    
    print("\n🧪 Testing mixed content...")
    print("=" * 50)
    
    mixed_content = """
    User Information:
    Name: Crystal White
    Email: davisjesus@example.org
    Phone: 010-7658-5153
    SSN: 887-07-7325
    Credit Card: 4468-6779-7028-4776
    UUID: 665ef2db-cd63-4086-81e9-661ccaf8dd20
    """
    
    expected_masked = """
    User Information:
    Name: Crystal *****
    Email: d*********@example.org
    Phone: 010-7658-****
    SSN: 887-07-****
    Credit Card: 4468-6779-7028-****
    UUID: 665ef2db-cd63-4086-81e9-************
    """
    
    result = mask_sensitive_data(mixed_content)
    
    print("Original content:")
    print(mixed_content)
    print("\nMasked content:")
    print(result)
    
    return True

if __name__ == "__main__":
    success = test_masking()
    test_mixed_content()
    
    if success:
        print("\n✅ All masking tests completed successfully!")
        sys.exit(0)
    else:
        print("\n❌ Some tests failed!")
        sys.exit(1)
