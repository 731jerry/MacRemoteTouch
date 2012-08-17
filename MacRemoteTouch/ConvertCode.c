////
////  ConvertCode.c
////  MacRemoteTouch
////
////  Created by Jerry Zhu on 8/17/12.
////  Copyright (c) 2012 Jerry Zhu. All rights reserved.
////
//
//#include <stdint.h>
//#include <stdio.h>
//#include <ApplicationServices/ApplicationServices.h>
//#include <Carbon/Carbon.h>
//
//CGKeyCode keyCodeForCharWithLayout(const char c,
//                                   const UCKeyboardLayout *uchrHeader);
//
//CGKeyCode keyCodeForChar(const char c)
//{
//	CFDataRef currentLayoutData;
//	TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
//    
//	if (currentKeyboard == NULL) {
//		fputs("Could not find keyboard layout\n", stderr);
//		return UINT16_MAX;
//	}
//    
//	currentLayoutData = TISGetInputSourceProperty(currentKeyboard,
//                                                  kTISPropertyUnicodeKeyLayoutData);
//	CFRelease(currentKeyboard);
//	if (currentLayoutData == NULL) {
//		fputs("Could not find layout data\n", stderr);
//		return UINT16_MAX;
//	}
//    
//	return keyCodeForCharWithLayout(c,
//                                    (const UCKeyboardLayout *)CFDataGetBytePtr(currentLayoutData));
//}
//
///* Beware! Messy, incomprehensible code ahead!
// * TODO: XXX: FIXME! Please! */
//CGKeyCode keyCodeForCharWithLayout(const char c,
//                                   const UCKeyboardLayout *uchrHeader)
//{
//	uint8_t *uchrData = (uint8_t *)uchrHeader;
//	UCKeyboardTypeHeader *uchrKeyboardList = uchrHeader->keyboardTypeList;
//    
//	/* Loop through the keyboard type list. */
//	ItemCount i, j;
//	for (i = 0; i < uchrHeader->keyboardTypeCount; ++i) {
//		/* Get a pointer to the keyToCharTable structure. */
//		UCKeyToCharTableIndex *uchrKeyIX = (UCKeyToCharTableIndex *)
//		(uchrData + (uchrKeyboardList[i].keyToCharTableIndexOffset));
//        
//		/* Not sure what this is for but it appears to be a safeguard... */
//		UCKeyStateRecordsIndex *stateRecordsIndex;
//		if (uchrKeyboardList[i].keyStateRecordsIndexOffset != 0) {
//			stateRecordsIndex = (UCKeyStateRecordsIndex *)
//            (uchrData + (uchrKeyboardList[i].keyStateRecordsIndexOffset));
//            
//			if ((stateRecordsIndex->keyStateRecordsIndexFormat) !=
//			    kUCKeyStateRecordsIndexFormat) {
//				stateRecordsIndex = NULL;
//			}
//		} else {
//			stateRecordsIndex = NULL;
//		}
//        
//		/* Make sure structure is a table that can be searched. */
//		if ((uchrKeyIX->keyToCharTableIndexFormat) != kUCKeyToCharTableIndexFormat) {
//			continue;
//		}
//        
//		/* Check the table of each keyboard for character */
//		for (j = 0; j < uchrKeyIX->keyToCharTableCount; ++j) {
//			UCKeyOutput *keyToCharData =
//            (UCKeyOutput *)(uchrData + (uchrKeyIX->keyToCharTableOffsets[j]));
//            
//			/* Check THIS table of the keyboard for the character. */
//			UInt16 k;
//			for (k = 0; k < uchrKeyIX->keyToCharTableSize; ++k) {
//				/* Here's the strange safeguard again... */
//				if ((keyToCharData[k] & kUCKeyOutputTestForIndexMask) ==
//				    kUCKeyOutputStateIndexMask) {
//					long keyIndex = (keyToCharData[k] & kUCKeyOutputGetIndexMask);
//					if (stateRecordsIndex != NULL &&
//						keyIndex <= (stateRecordsIndex->keyStateRecordCount)) {
//						UCKeyStateRecord *stateRecord = (UCKeyStateRecord *)
//                        (uchrData +
//                         (stateRecordsIndex->keyStateRecordOffsets[keyIndex]));
//                        
//						if ((stateRecord->stateZeroCharData) == c) {
//							return (CGKeyCode)k;
//						}
//					} else if (keyToCharData[k] == c) {
//						return (CGKeyCode)k;
//					}
//				} else if (((keyToCharData[k] & kUCKeyOutputTestForIndexMask)
//							!= kUCKeyOutputSequenceIndexMask) &&
//						   keyToCharData[k] != 0xFFFE &&
//				           keyToCharData[k] != 0xFFFF &&
//						   keyToCharData[k] == c) {
//					return (CGKeyCode)k;
//				}
//			}
//		}
//	}
//    
//	return UINT16_MAX;
//}
