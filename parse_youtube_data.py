#!/usr/bin/env python3
"""Parse raw YouTube Studio data into clean structured format."""
import re
import json

raw_data = open('/home/user/-/.claude/skills/youtube-planner/data/samples/raw-youtube-studio-data.txt', 'r').read()

# Date pattern to split records
date_pattern = r'((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},\s+\d{4})'

# Find all dates and their positions
dates = [(m.group(), m.start(), m.end()) for m in re.finditer(date_pattern, raw_data)]

videos = []
for i, (date, start, end) in enumerate(dates):
    # Title is the text before this date (after previous record's numbers)
    # Find the title by looking backward from the date
    # The title starts after the last number sequence from the previous record

    if i == 0:
        # First record - title is between header and first date
        # Find where the header numbers end and the first title begins
        title_text = raw_data[:start]
        # Remove header and initial numbers
        # Look for the last occurrence of a number sequence followed by Korean text
        korean_match = re.search(r'[\d.]+\s*([\uac00-\ud7af\u1100-\u11ff\u3130-\u318f\uA960-\uA97F\uD7B0-\uD7FF].*?)$', title_text)
        if korean_match:
            title = korean_match.group(1).strip()
        else:
            # Try to find Korean text near the end
            korean_parts = re.findall(r'([\uac00-\ud7af\u1100-\u11ff\u3130-\u318f\uA960-\uA97F\uD7B0-\uD7FF\s!?.,ㅋㅎㅠㅜ❤️♥♡\[\]\(\)~:…·\-_\'"]+)', title_text)
            title = korean_parts[-1].strip() if korean_parts else "Unknown"
    else:
        prev_end = dates[i-1][2]
        between = raw_data[prev_end:start]
        # Title is the Korean text part at the end of 'between'
        # Numbers come first, then the title
        # Find where Korean text starts (after the last pure number sequence)

        # Split by looking for Korean characters
        # The title typically starts with Korean characters after a number
        match = re.search(r'([\uac00-\ud7af\u1100-\u11ff\u3130-\u318f\uA960-\uA97F\uD7B0-\uD7FFㅋㅎㅠㅜ][\uac00-\ud7af\u1100-\u11ff\u3130-\u318f\uA960-\uA97F\uD7B0-\uD7FF\s!?.,ㅋㅎㅠㅜ❤️♥♡\[\]\(\)~:…·\-_\'"0-9a-zA-Z%\u0021-\u007E]+)$', between)
        if match:
            title = match.group(1).strip()
        else:
            title = between.strip()

    # Numbers after the date
    if i < len(dates) - 1:
        numbers_text = raw_data[end:dates[i+1][1]]
    else:
        numbers_text = raw_data[end:]

    # Extract all numbers from the numbers section
    nums = re.findall(r'[\d,]+\.?\d*', numbers_text)

    # Clean numbers (remove commas)
    clean_nums = []
    for n in nums:
        try:
            clean_nums.append(float(n.replace(',', '')))
        except:
            clean_nums.append(0)

    # Map to fields based on position
    # The order after date should be:
    # duration_seconds, time_string(?), avg_view_pct, valid_views, cpm, rpm, playback_cpm, ad_impressions, views, watch_hours, subs, revenue, impressions, ctr

    video = {
        'title': title,
        'date': date,
        'numbers': clean_nums[:20]  # Take first 20 numbers max
    }

    videos.append(video)

# Now let's try a better parsing approach - use the date as anchor and extract views
# Views tend to be a large number (5-6 digits typically)

# Let me re-parse with a cleaner approach
# The raw data format per line (tab-separated in original):
# title | date | duration_sec | avg_watch_time | avg_view_pct | valid_views | cpm | rpm | playback_cpm | ad_impressions | views | watch_hours | subscribers | revenue | impressions | ctr

# Actually, let me just extract what we can reliably: title, date, and the main numbers

print(f"Found {len(videos)} videos")
print()

# Let's build a cleaner dataset
# For each video, try to identify views (usually 5-7 digit number)
# The numbers after date typically follow this pattern:
# [duration_sec] [0:MM:SS components -> multiple small numbers] [pct ~30-70] [views 5-7 digits] [small CPM numbers] ...

output = []
for v in videos:
    nums = v['numbers']
    title = v['title']
    date = v['date']

    # Clean up title - remove leading numbers and punctuation
    title = re.sub(r'^[\d.,\s]+', '', title)
    title = title.strip()

    if not title or len(nums) < 5:
        continue

    # Try to identify views - typically the largest number that's reasonable for views
    # Views should be between 1000 and 10,000,000
    potential_views = [n for n in nums if 1000 <= n <= 10000000]
    views = max(potential_views) if potential_views else 0

    output.append({
        'title': title,
        'date': date,
        'views': int(views),
        'all_nums': [int(n) if n == int(n) else n for n in nums[:8]]
    })

# Sort by views descending
output.sort(key=lambda x: x['views'], reverse=True)

# Write clean markdown output
with open('/home/user/-/.claude/skills/youtube-planner/data/samples/video-performance.md', 'w') as f:
    f.write('# 코너(korner) 채널 영상 성과 데이터\n\n')
    f.write(f'> 총 {len(output)}개 영상 분석 (YouTube Studio 원본 데이터 기반)\n\n')

    # Top 30
    f.write('## TOP 30 조회수 영상\n\n')
    f.write('| 순위 | 제목 | 게시일 | 조회수 |\n')
    f.write('|------|------|--------|--------|\n')
    for i, v in enumerate(output[:30]):
        f.write(f'| {i+1} | {v["title"]} | {v["date"]} | {v["views"]:,} |\n')

    # Category analysis
    f.write('\n## 카테고리별 분류\n\n')

    categories = {
        '복불복/챌린지': ['복불복', '챌린지', '100만원', '안벗으면', '안밟으면', '안나오면', '먹으면', '벌칙', '대결'],
        '너프전쟁': ['너프전쟁', 'Nerf War', '너프건', '배틀그라운드'],
        '여행': ['여행', '캠핑', '경포대', '계곡', '제부도', '대천', '강화도', '부산', '대만', '보라카이', '베트남', '태국', '세부', '키르기즈스탄'],
        '동생/가족': ['동생', '여동생', '내동생', '사촌'],
        '먹방/요리': ['먹방', '요리', '먹어보자', '맛있다', '음식', '라면', '치킨', '삼겹살', '핫도그', '햄버거', '육개장', '떡볶이'],
        '몰카/장난': ['몰카', '장난', '미행', '몰래'],
        '커플/연애': ['전남친', '전여친', '커플', '사귀', '재결합', '연애', '사랑'],
        '귀신/공포': ['귀신', '공포', '고스트', '무서운'],
        '실험': ['실험', '진짜일까'],
    }

    for cat_name, keywords in categories.items():
        matching = [v for v in output if any(k in v['title'] for k in keywords)]
        if matching:
            avg_views = sum(v['views'] for v in matching) // len(matching)
            f.write(f'### {cat_name} ({len(matching)}개, 평균 조회수: {avg_views:,})\n')
            for v in matching[:5]:
                f.write(f'- {v["title"]} ({v["date"]}) - {v["views"]:,}회\n')
            if len(matching) > 5:
                f.write(f'- ... 외 {len(matching)-5}개\n')
            f.write('\n')

    # Year analysis
    f.write('## 연도별 분석\n\n')
    year_data = {}
    for v in output:
        year = v['date'].split(', ')[-1]
        if year not in year_data:
            year_data[year] = []
        year_data[year].append(v)

    for year in sorted(year_data.keys(), reverse=True):
        vids = year_data[year]
        avg = sum(v['views'] for v in vids) // len(vids)
        top = max(vids, key=lambda x: x['views'])
        f.write(f'### {year}년 ({len(vids)}개 영상, 평균 조회수: {avg:,})\n')
        f.write(f'- 최고 조회수: {top["title"]} ({top["views"]:,}회)\n\n')

    # Title patterns
    f.write('## 제목 패턴 분석\n\n')

    exclaim_vids = [v for v in output if v['title'].count('!') >= 3]
    laugh_vids = [v for v in output if 'ㅋ' in v['title']]
    question_vids = [v for v in output if '?' in v['title']]
    ellipsis_vids = [v for v in output if '..' in v['title']]

    f.write(f'- 느낌표 다수 (!!!): {len(exclaim_vids)}개, 평균 {sum(v["views"] for v in exclaim_vids)//max(len(exclaim_vids),1):,}회\n')
    f.write(f'- ㅋㅋㅋ 포함: {len(laugh_vids)}개, 평균 {sum(v["views"] for v in laugh_vids)//max(len(laugh_vids),1):,}회\n')
    f.write(f'- 물음표 포함: {len(question_vids)}개, 평균 {sum(v["views"] for v in question_vids)//max(len(question_vids),1):,}회\n')
    f.write(f'- 말줄임(..) 포함: {len(ellipsis_vids)}개, 평균 {sum(v["views"] for v in ellipsis_vids)//max(len(ellipsis_vids),1):,}회\n')

print("Parsed and saved to video-performance.md")

# Also save as JSON for programmatic use
with open('/home/user/-/.claude/skills/youtube-planner/data/samples/video-data.json', 'w') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"Saved {len(output)} videos to video-data.json")
