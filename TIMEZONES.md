# Timezone Reference

This file contains common timezone identifiers for use with the `TZ` environment variable.

## How to Use
Set the `TZ` environment variable to one of these timezone identifiers:
```bash
-e TZ=America/New_York
```

## Common Timezones by Region

### Americas
- `America/New_York` - Eastern Time (US & Canada)
- `America/Chicago` - Central Time (US & Canada)
- `America/Denver` - Mountain Time (US & Canada)
- `America/Los_Angeles` - Pacific Time (US & Canada)
- `America/Phoenix` - Mountain Time (Arizona, no DST)
- `America/Anchorage` - Alaska Time
- `America/Honolulu` - Hawaii Time
- `America/Toronto` - Eastern Time (Canada)
- `America/Vancouver` - Pacific Time (Canada)
- `America/Mexico_City` - Central Time (Mexico)
- `America/Sao_Paulo` - Brazil Time
- `America/Argentina/Buenos_Aires` - Argentina Time

### Europe
- `Europe/London` - Greenwich Mean Time / British Summer Time
- `Europe/Dublin` - Ireland Time
- `Europe/Paris` - Central European Time (France)
- `Europe/Berlin` - Central European Time (Germany)
- `Europe/Rome` - Central European Time (Italy)
- `Europe/Madrid` - Central European Time (Spain)
- `Europe/Amsterdam` - Central European Time (Netherlands)
- `Europe/Brussels` - Central European Time (Belgium)
- `Europe/Zurich` - Central European Time (Switzerland)
- `Europe/Vienna` - Central European Time (Austria)
- `Europe/Stockholm` - Central European Time (Sweden)
- `Europe/Oslo` - Central European Time (Norway)
- `Europe/Copenhagen` - Central European Time (Denmark)
- `Europe/Helsinki` - Eastern European Time (Finland)
- `Europe/Warsaw` - Central European Time (Poland)
- `Europe/Prague` - Central European Time (Czech Republic)
- `Europe/Budapest` - Central European Time (Hungary)
- `Europe/Bucharest` - Eastern European Time (Romania)
- `Europe/Athens` - Eastern European Time (Greece)
- `Europe/Istanbul` - Turkey Time
- `Europe/Moscow` - Moscow Time (Russia)

### Asia
- `Asia/Tokyo` - Japan Standard Time
- `Asia/Seoul` - Korea Standard Time
- `Asia/Shanghai` - China Standard Time
- `Asia/Hong_Kong` - Hong Kong Time
- `Asia/Singapore` - Singapore Time
- `Asia/Bangkok` - Indochina Time (Thailand)
- `Asia/Jakarta` - Western Indonesia Time
- `Asia/Manila` - Philippine Time
- `Asia/Kuala_Lumpur` - Malaysia Time
- `Asia/Kolkata` - India Standard Time
- `Asia/Karachi` - Pakistan Standard Time
- `Asia/Dhaka` - Bangladesh Time
- `Asia/Dubai` - Gulf Standard Time (UAE)
- `Asia/Qatar` - Arabian Standard Time
- `Asia/Riyadh` - Arabian Standard Time (Saudi Arabia)
- `Asia/Tehran` - Iran Standard Time
- `Asia/Baghdad` - Arabian Standard Time (Iraq)
- `Asia/Jerusalem` - Israel Standard Time

### Africa
- `Africa/Cairo` - Eastern European Time (Egypt)
- `Africa/Johannesburg` - South Africa Standard Time
- `Africa/Lagos` - West Africa Time (Nigeria)
- `Africa/Nairobi` - East Africa Time (Kenya)
- `Africa/Casablanca` - Western European Time (Morocco)
- `Africa/Algiers` - Central European Time (Algeria)
- `Africa/Tunis` - Central European Time (Tunisia)

### Australia & Pacific
- `Australia/Sydney` - Australian Eastern Time
- `Australia/Melbourne` - Australian Eastern Time
- `Australia/Brisbane` - Australian Eastern Time (no DST)
- `Australia/Perth` - Australian Western Time
- `Australia/Adelaide` - Australian Central Time
- `Australia/Darwin` - Australian Central Time (no DST)
- `Pacific/Auckland` - New Zealand Time
- `Pacific/Honolulu` - Hawaii-Aleutian Time
- `Pacific/Fiji` - Fiji Time
- `Pacific/Guam` - Chamorro Standard Time

### UTC and Special Zones
- `UTC` - Coordinated Universal Time (recommended for servers)
- `GMT` - Greenwich Mean Time (same as UTC)

## Complete List
For a complete list of all available timezone identifiers, see:
- [Wikipedia: List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
- [IANA Time Zone Database](https://www.iana.org/time-zones)

## Notes
- Use the full timezone identifier (e.g., `America/New_York`, not just `EST`)
- Timezone identifiers are case-sensitive
- Many timezones automatically handle Daylight Saving Time (DST)
- For servers, consider using `UTC` to avoid timezone-related issues
