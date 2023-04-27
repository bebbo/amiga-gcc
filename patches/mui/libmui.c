--- libmui.c	2023-04-27 12:59:33.348672817 +0200
+++ libmui.c	2023-04-27 12:51:04.728764400 +0200
@@ -35,7 +35,7 @@
   __asm volatile ("jsr a6@(-30:W)"
   : "=r" (_res)
   : "r" (_base), "r" (cl), "r" (tags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -55,7 +55,7 @@
   __asm volatile ("jsr a6@(-36:W)"
   : /* No output */
   : "r" (_base), "r" (obj)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d0", "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  LONG
@@ -74,7 +74,7 @@
   __asm volatile ("jsr a6@(-42:W)"
   : "=r" (_res)
   : "r" (_base), "r" (app), "r" (win), "r" (flags), "r" (title), "r" (gadgets), "r" (format), "r" (params)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -96,7 +96,7 @@
   __asm volatile ("jsr a6@(-48:W)"
   : "=r" (_res)
   : "r" (_base), "r" (type), "r" (tags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -119,7 +119,7 @@
   __asm volatile ("jsr a6@(-54:W)"
   : "=r" (_res)
   : "r" (_base), "r" (req), "r" (tags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -139,7 +139,7 @@
   __asm volatile ("jsr a6@(-60:W)"
   : /* No output */
   : "r" (_base), "r" (req)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d0", "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  LONG
@@ -179,7 +179,7 @@
   __asm volatile ("jsr a6@(-78:W)"
   : "=r" (_res)
   : "r" (_base), "r" (name)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -193,7 +193,7 @@
   __asm volatile ("jsr a6@(-84:W)"
   : /* No output */
   : "r" (_base), "r" (cl)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d0", "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  VOID
@@ -206,7 +206,7 @@
   __asm volatile ("jsr a6@(-90:W)"
   : /* No output */
   : "r" (_base), "r" (obj), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  VOID
@@ -219,7 +219,7 @@
   __asm volatile ("jsr a6@(-96:W)"
   : /* No output */
   : "r" (_base), "r" (obj), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  VOID
@@ -232,7 +232,7 @@
   __asm volatile ("jsr a6@(-102:W)"
   : /* No output */
   : "r" (_base), "r" (obj), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
 struct Library;
@@ -251,7 +251,7 @@
   __asm volatile ("jsr a6@(-108:W)"
   : "=r" (_res)
   : "r" (_base), "r" (base), "r" (supername), "r" (supermcc), "r" (datasize), "r" (dispatcher)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -266,7 +266,7 @@
   __asm volatile ("jsr a6@(-114:W)"
   : "=r" (_res)
   : "r" (_base), "r" (mcc)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -281,7 +281,7 @@
   __asm volatile ("jsr a6@(-120:W)"
   : "=r" (_res)
   : "r" (_base), "r" (type), "r" (params)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -306,7 +306,7 @@
   __asm volatile ("jsr a6@(-126:W)"
   : "=r" (_res)
   : "r" (_base), "r" (obj), "r" (l), "r" (t), "r" (w), "r" (h), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -324,7 +324,7 @@
   __asm volatile ("jsr a6@(-156:W)"
   : "=r" (_res)
   : "r" (_base), "r" (mri), "r" (spec), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -339,7 +339,7 @@
   __asm volatile ("jsr a6@(-162:W)"
   : /* No output */
   : "r" (_base), "r" (mri), "r" (pen)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
 struct MUI_RenderInfo;
@@ -357,7 +357,7 @@
   __asm volatile ("jsr a6@(-168:W)"
   : "=r" (_res)
   : "r" (_base), "r" (mri), "r" (l), "r" (t), "r" (w), "r" (h)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -372,7 +372,7 @@
   __asm volatile ("jsr a6@(-174:W)"
   : /* No output */
   : "r" (_base), "r" (mri), "r" (h)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d0", "d1", "fp0", "fp1", "cc", "memory");
 }
 
 struct MUI_RenderInfo;
@@ -388,7 +388,7 @@
   __asm volatile ("jsr a6@(-180:W)"
   : "=r" (_res)
   : "r" (_base), "r" (mri), "r" (region)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -403,7 +403,7 @@
   __asm volatile ("jsr a6@(-186:W)"
   : /* No output */
   : "r" (_base), "r" (mri), "r" (region)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d0", "d1", "fp0", "fp1", "cc", "memory");
 }
 
 struct MUI_RenderInfo;
@@ -418,7 +418,7 @@
   __asm volatile ("jsr a6@(-192:W)"
   : "=r" (_res)
   : "r" (_base), "r" (mri), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -433,7 +433,7 @@
   __asm volatile ("jsr a6@(-198:W)"
   : /* No output */
   : "r" (_base), "r" (mri), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
 }
 
  ULONG
@@ -446,7 +446,7 @@
   __asm volatile ("jsr a6@(-216:W)"
   : "=r" (_res)
   : "r" (_base), "r" (obj)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -460,7 +460,7 @@
   __asm volatile ("jsr a6@(-222:W)"
   : "=r" (_res)
   : "r" (_base), "r" (obj)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "d1", "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -479,7 +479,7 @@
   __asm volatile ("jsr a6@(-228:W)"
   : "=r" (_res)
   : "r" (_base), "r" (obj), "r" (l), "r" (t), "r" (w), "r" (h), "r" (flags)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "a1", "fp0", "fp1", "cc", "memory");
   return _res;
 }
 
@@ -494,7 +494,7 @@
   __asm volatile ("jsr a6@(-234:W)"
   : /* No output */
   : "r" (_base), "r" (obj), "r" (x), "r" (y)
-  : "d1", "a0", "a1", "fp0", "fp1", "cc", "memory");
+  : "a1", "fp0", "fp1", "cc", "memory");
 }
 
 
