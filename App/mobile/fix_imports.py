import os
import re

base_dir = r"C:\Users\Mert\Documents\GitHub\Nexthood\App\mobile\lib"

replacements = [
    (r"import\s+'\.\./\.\./core/", r"import 'package:mahalle_connect/core/"),
    (r"import\s+'\.\./core/", r"import 'package:mahalle_connect/core/"),
    (r"import\s+'core/", r"import 'package:mahalle_connect/core/"),
    (r"import\s+'\.\./data/", r"import 'package:mahalle_connect/data/"),
    (r"import\s+'\.\./\.\./data/", r"import 'package:mahalle_connect/data/"),
    (r"import\s+'\.\./screens/", r"import 'package:mahalle_connect/features/events/presentation/screens/"),
    (r"import\s+'\.\./widgets/event_card\.dart';", r"import 'package:mahalle_connect/features/events/presentation/widgets/event_card.dart';"),
    (r"import\s+'\.\./widgets/bottom_nav_bar\.dart';", r"import 'package:mahalle_connect/core/presentation/widgets/bottom_nav_bar.dart';"),
    (r"import\s+'\.\./\.\./widgets/event_card\.dart';", r"import 'package:mahalle_connect/features/events/presentation/widgets/event_card.dart';"),
    (r"import\s+'\.\./\.\./widgets/bottom_nav_bar\.dart';", r"import 'package:mahalle_connect/core/presentation/widgets/bottom_nav_bar.dart';"),
    (r"import\s+'widgets/bottom_nav_bar\.dart';", r"import 'package:mahalle_connect/core/presentation/widgets/bottom_nav_bar.dart';"),
    (r"import\s+'widgets/event_card\.dart';", r"import 'package:mahalle_connect/features/events/presentation/widgets/event_card.dart';"),
    (r"import\s+'screens/", r"import 'package:mahalle_connect/features/events/presentation/screens/"),
]

for root, _, files in os.walk(base_dir):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            new_content = content
            for p, r in replacements:
                new_content = re.sub(p, r, new_content)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as file:
                    file.write(new_content)
print("Done replacements")
