#!/usr/bin/env python3
"""
Create architecture diagram for CloudTrail stack
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import matplotlib.lines as mlines

# Create figure and axis
fig, ax = plt.subplots(1, 1, figsize=(14, 10))
ax.set_xlim(0, 14)
ax.set_ylim(0, 10)
ax.axis('off')

# Define colors
aws_orange = '#FF9900'
aws_blue = '#232F3E'
light_blue = '#4B9CD3'
light_gray = '#F0F0F0'
dark_gray = '#555555'

# Main AWS Account container
account_box = FancyBboxPatch(
    (0.5, 0.5), 13, 9,
    boxstyle="round,pad=0.05",
    facecolor=light_gray,
    edgecolor=aws_blue,
    linewidth=2
)
ax.add_patch(account_box)

# Title
ax.text(7, 9.2, 'AWS Account - CloudTrail Architecture',
        fontsize=16, fontweight='bold', ha='center', color=aws_blue)

# CloudTrail (top center)
cloudtrail = FancyBboxPatch(
    (5.5, 7), 3, 1.2,
    boxstyle="round,pad=0.02",
    facecolor='white',
    edgecolor=aws_orange,
    linewidth=2
)
ax.add_patch(cloudtrail)
ax.text(7, 7.6, 'CloudTrail', fontsize=11, fontweight='bold', ha='center')
ax.text(7, 7.3, '(Multi-Region)', fontsize=9, ha='center', style='italic')

# CloudTrail Lake (right)
lake = FancyBboxPatch(
    (10, 6.8), 3, 1.4,
    boxstyle="round,pad=0.02",
    facecolor='white',
    edgecolor=light_blue,
    linewidth=2
)
ax.add_patch(lake)
ax.text(11.5, 7.7, 'CloudTrail Lake', fontsize=11, fontweight='bold', ha='center')
ax.text(11.5, 7.4, '7-day retention', fontsize=9, ha='center')
ax.text(11.5, 7.1, 'SQL Analytics', fontsize=9, ha='center', style='italic')

# S3 Bucket (left)
s3_bucket = FancyBboxPatch(
    (1, 4.5), 3, 1.4,
    boxstyle="round,pad=0.02",
    facecolor='white',
    edgecolor=aws_orange,
    linewidth=2
)
ax.add_patch(s3_bucket)
ax.text(2.5, 5.5, 'S3 Bucket', fontsize=11, fontweight='bold', ha='center')
ax.text(2.5, 5.2, 'Encrypted (KMS)', fontsize=9, ha='center')
ax.text(2.5, 4.9, 'Versioning Enabled', fontsize=9, ha='center', style='italic')

# CloudWatch Logs (center)
cw_logs = FancyBboxPatch(
    (5.5, 4.5), 3, 1.4,
    boxstyle="round,pad=0.02",
    facecolor='white',
    edgecolor=aws_orange,
    linewidth=2
)
ax.add_patch(cw_logs)
ax.text(7, 5.5, 'CloudWatch', fontsize=11, fontweight='bold', ha='center')
ax.text(7, 5.2, 'Logs', fontsize=11, fontweight='bold', ha='center')
ax.text(7, 4.9, '30-day retention', fontsize=9, ha='center', style='italic')

# KMS Key (right)
kms = FancyBboxPatch(
    (10, 4.5), 3, 1.4,
    boxstyle="round,pad=0.02",
    facecolor='white',
    edgecolor=dark_gray,
    linewidth=2
)
ax.add_patch(kms)
ax.text(11.5, 5.5, 'KMS Key', fontsize=11, fontweight='bold', ha='center')
ax.text(11.5, 5.2, 'Auto-rotation', fontsize=9, ha='center')
ax.text(11.5, 4.9, 'Customer Managed', fontsize=9, ha='center', style='italic')

# S3 Lifecycle (below S3)
lifecycle = FancyBboxPatch(
    (1, 2.5), 3, 1.2,
    boxstyle="round,pad=0.02",
    facecolor='#FFE5B4',
    edgecolor=aws_orange,
    linewidth=1.5
)
ax.add_patch(lifecycle)
ax.text(2.5, 3.3, 'Lifecycle Policies', fontsize=10, fontweight='bold', ha='center')
ax.text(2.5, 3.0, '7d → IA', fontsize=8, ha='center')
ax.text(2.5, 2.75, '30d → Glacier', fontsize=8, ha='center')
ax.text(2.5, 2.5, '60d → Deep Archive', fontsize=8, ha='center')

# Alarms & Metrics (below CloudWatch)
alarms = FancyBboxPatch(
    (5.5, 2.5), 3, 1.2,
    boxstyle="round,pad=0.02",
    facecolor='#FFE5B4',
    edgecolor=aws_orange,
    linewidth=1.5
)
ax.add_patch(alarms)
ax.text(7, 3.3, 'Alarms & Metrics', fontsize=10, fontweight='bold', ha='center')
ax.text(7, 3.0, 'Root Account Usage', fontsize=8, ha='center')
ax.text(7, 2.75, 'Unauthorized API', fontsize=8, ha='center')
ax.text(7, 2.5, 'Real-time Alerts', fontsize=8, ha='center', style='italic')

# Access Logs Bucket (bottom right)
access_logs = FancyBboxPatch(
    (10, 2.5), 3, 1.2,
    boxstyle="round,pad=0.02",
    facecolor='#F0F0F0',
    edgecolor=dark_gray,
    linewidth=1.5
)
ax.add_patch(access_logs)
ax.text(11.5, 3.3, 'Access Logs', fontsize=10, fontweight='bold', ha='center')
ax.text(11.5, 3.0, 'Separate Bucket', fontsize=8, ha='center')
ax.text(11.5, 2.75, '30-day retention', fontsize=8, ha='center')

# Insights (bottom left of CloudTrail)
insights = FancyBboxPatch(
    (1, 6.8), 3, 1.4,
    boxstyle="round,pad=0.02",
    facecolor='#FFE5B4',
    edgecolor=light_blue,
    linewidth=1.5
)
ax.add_patch(insights)
ax.text(2.5, 7.7, 'CloudTrail Insights', fontsize=10, fontweight='bold', ha='center')
ax.text(2.5, 7.4, 'API Call Rate', fontsize=8, ha='center')
ax.text(2.5, 7.1, 'Error Rate Analysis', fontsize=8, ha='center')

# Draw arrows
# CloudTrail to Lake
arrow1 = FancyArrowPatch((8.5, 7.6), (10, 7.5),
                        connectionstyle="arc3,rad=0.1",
                        arrowstyle='->',
                        mutation_scale=20,
                        linewidth=2,
                        color=aws_blue)
ax.add_patch(arrow1)

# CloudTrail to S3
arrow2 = FancyArrowPatch((6.5, 7), (3, 5.9),
                        connectionstyle="arc3,rad=0.3",
                        arrowstyle='->',
                        mutation_scale=20,
                        linewidth=2,
                        color=aws_blue)
ax.add_patch(arrow2)

# CloudTrail to CloudWatch
arrow3 = FancyArrowPatch((7, 7), (7, 5.9),
                        connectionstyle="arc3,rad=0",
                        arrowstyle='->',
                        mutation_scale=20,
                        linewidth=2,
                        color=aws_blue)
ax.add_patch(arrow3)

# CloudTrail to KMS (encryption)
arrow4 = FancyArrowPatch((8.5, 7.3), (10, 5.7),
                        connectionstyle="arc3,rad=-0.3",
                        arrowstyle='<->',
                        mutation_scale=15,
                        linewidth=1.5,
                        color=dark_gray,
                        linestyle='dashed')
ax.add_patch(arrow4)
ax.text(9.2, 6.5, 'encrypts', fontsize=7, style='italic', color=dark_gray)

# S3 to Lifecycle
arrow5 = FancyArrowPatch((2.5, 4.5), (2.5, 3.7),
                        connectionstyle="arc3,rad=0",
                        arrowstyle='->',
                        mutation_scale=15,
                        linewidth=1.5,
                        color=aws_orange)
ax.add_patch(arrow5)

# CloudWatch to Alarms
arrow6 = FancyArrowPatch((7, 4.5), (7, 3.7),
                        connectionstyle="arc3,rad=0",
                        arrowstyle='->',
                        mutation_scale=15,
                        linewidth=1.5,
                        color=aws_orange)
ax.add_patch(arrow6)

# S3 to Access Logs
arrow7 = FancyArrowPatch((4, 5), (10, 3.5),
                        connectionstyle="arc3,rad=0.5",
                        arrowstyle='->',
                        mutation_scale=15,
                        linewidth=1.5,
                        color=dark_gray,
                        linestyle='dashed')
ax.add_patch(arrow7)
ax.text(7, 3.8, 'logs access', fontsize=7, style='italic', color=dark_gray)

# CloudTrail to Insights
arrow8 = FancyArrowPatch((5.5, 7.5), (4, 7.5),
                        connectionstyle="arc3,rad=0",
                        arrowstyle='->',
                        mutation_scale=15,
                        linewidth=1.5,
                        color=light_blue)
ax.add_patch(arrow8)

# Add legend
legend_elements = [
    mlines.Line2D([0], [0], color=aws_blue, lw=2, label='Data Flow'),
    mlines.Line2D([0], [0], color=dark_gray, lw=1.5, linestyle='dashed', label='Encryption/Logging'),
    patches.Patch(facecolor='white', edgecolor=aws_orange, label='AWS Services'),
    patches.Patch(facecolor='#FFE5B4', edgecolor=aws_orange, label='Configuration'),
    patches.Patch(facecolor='white', edgecolor=light_blue, label='Analytics')
]
ax.legend(handles=legend_elements, loc='lower center', ncol=5, frameon=False, fontsize=9)

# Add note about cost optimization
ax.text(7, 0.8, 'Cost Optimization: Progressive storage tiering + minimal Lake retention',
        fontsize=9, ha='center', style='italic', color=dark_gray)

plt.title('CloudTrail Security & Compliance Architecture', fontsize=14, fontweight='bold', pad=20)
plt.tight_layout()
plt.savefig('architecture-diagram.png', dpi=300, bbox_inches='tight', facecolor='white')
print("Architecture diagram saved as 'architecture-diagram.png'")