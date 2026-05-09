# Layout Algorithms for Obsidian Canvas

Detailed algorithms for positioning nodes in MindMap and Freeform layouts.

## Layout Principles

### Universal Spacing Constants

```
HORIZONTAL_SPACING = 320  // Minimum horizontal space between node centers
VERTICAL_SPACING = 200    // Minimum vertical space between node centers
NODE_PADDING = 20         // Internal padding within nodes
```

### Collision Detection

Before finalizing any node position, verify:

```python
def check_collision(node1, node2):
    """Returns True if nodes overlap or are too close"""
    center1_x = node1.x + node1.width / 2
    center1_y = node1.y + node1.height / 2
    center2_x = node2.x + node2.width / 2
    center2_y = node2.y + node2.height / 2

    dx = abs(center1_x - center2_x)
    dy = abs(center1_y - center2_y)

    min_dx = (node1.width + node2.width) / 2 + HORIZONTAL_SPACING
    min_dy = (node1.height + node2.height) / 2 + VERTICAL_SPACING

    return dx < min_dx or dy < min_dy
```

## MindMap Layout Algorithm

### 1. Radial Tree Layout

Place root at center, arrange children radially.

#### Step 1: Position Root Node

```python
root = {
    "x": 0 - (root_width / 2),  # Center horizontally
    "y": 0 - (root_height / 2), # Center vertically
    "width": root_width,
    "height": root_height
}
```

#### Step 2: Calculate Primary Branch Positions

Distribute first-level children around root:

```python
def position_primary_branches(root, children, radius=400):
    """Position first-level children in a circle around root"""
    n = len(children)
    angle_step = 2 * pi / n

    positions = []
    for i, child in enumerate(children):
        angle = i * angle_step

        # Calculate position on circle
        x = root.center_x + radius * cos(angle) - child.width / 2
        y = root.center_y + radius * sin(angle) - child.height / 2

        positions.append({"x": x, "y": y})

    return positions
```

**Radius Selection:**
- Small canvases (≤10 children): 400px
- Medium canvases (11-20 children): 500px
- Large canvases (>20 children): 600px

#### Step 3: Position Secondary Branches

For each primary branch, arrange its children:

**Horizontal Layout** (preferred for most cases):

```python
def position_secondary_horizontal(parent, children, distance=350):
    """Arrange children horizontally to the right of parent"""
    n = len(children)
    total_height = sum(child.height for child in children)
    total_spacing = (n - 1) * VERTICAL_SPACING

    # Start position (top of vertical arrangement)
    start_y = parent.center_y - (total_height + total_spacing) / 2

    positions = []
    current_y = start_y

    for child in children:
        x = parent.x + parent.width + distance
        y = current_y

        positions.append({"x": x, "y": y})
        current_y += child.height + VERTICAL_SPACING

    return positions
```

#### Step 4: Balance and Adjust

After initial placement, check for collisions and adjust:

```python
def balance_layout(nodes):
    """Adjust nodes to prevent overlaps"""
    max_iterations = 10

    for iteration in range(max_iterations):
        collisions = find_all_collisions(nodes)
        if not collisions:
            break

        for node1, node2 in collisions:
            # Move node2 away from node1
            dx = node2.center_x - node1.center_x
            dy = node2.center_y - node1.center_y
            distance = sqrt(dx*dx + dy*dy)

            min_dist = calculate_min_distance(node1, node2)

            if distance > 0:
                move_x = (dx / distance) * (min_dist - distance) / 2
                move_y = (dy / distance) * (min_dist - distance) / 2

                node2.x += move_x
                node2.y += move_y
```

### 2. Tree Layout (Hierarchical Top-Down)

Alternative for deep hierarchies.

```python
def position_tree_layout(root, tree):
    """Top-down tree layout"""
    # Level 0 (root)
    root.x = 0 - root.width / 2
    root.y = 0 - root.height / 2

    # Process each level
    for level in range(1, max_depth):
        nodes_at_level = get_nodes_at_level(tree, level)

        total_width = sum(node.width for node in nodes_at_level)
        total_spacing = (len(nodes_at_level) - 1) * HORIZONTAL_SPACING

        start_x = -(total_width + total_spacing) / 2
        y = level * (150 + VERTICAL_SPACING)

        current_x = start_x
        for node in nodes_at_level:
            node.x = current_x
            node.y = y
            current_x += node.width + HORIZONTAL_SPACING
```

## Freeform Layout Algorithm

### 1. Content-Based Grouping

```python
def identify_groups(nodes, content_structure):
    """Group nodes by semantic relationships"""
    groups = []

    for section in content_structure:
        group_nodes = [node for node in nodes if node.section == section]

        if len(group_nodes) > 1:
            groups.append({
                "label": section.title,
                "nodes": group_nodes
            })

    return groups
```

### 2. Grid-Based Zone Layout

```python
def layout_zones(groups, canvas_width=2000, canvas_height=1500):
    """Arrange groups in grid zones"""
    n_groups = len(groups)

    cols = ceil(sqrt(n_groups))
    rows = ceil(n_groups / cols)

    zone_width = canvas_width / cols
    zone_height = canvas_height / rows

    zones = []
    for i, group in enumerate(groups):
        col = i % cols
        row = i // cols

        zone = {
            "x": col * zone_width - canvas_width / 2,
            "y": row * zone_height - canvas_height / 2,
            "width": zone_width * 0.9,
            "height": zone_height * 0.9,
            "group": group
        }
        zones.append(zone)

    return zones
```

### 3. Cross-Zone Connections

```python
def calculate_edge_path(from_node, to_node):
    """Determine edge connection points"""
    from_center = (from_node.x + from_node.width/2,
                   from_node.y + from_node.height/2)
    to_center = (to_node.x + to_node.width/2,
                 to_node.y + to_node.height/2)

    dx = to_center[0] - from_center[0]
    dy = to_center[1] - from_center[1]

    if abs(dx) > abs(dy):
        from_side = "right" if dx > 0 else "left"
        to_side = "left" if dx > 0 else "right"
    else:
        from_side = "bottom" if dy > 0 else "top"
        to_side = "top" if dy > 0 else "bottom"

    return {
        "fromSide": from_side,
        "toSide": to_side
    }
```

## Common Layout Patterns

### Timeline Layout

```python
def layout_timeline(events, direction="horizontal"):
    if direction == "horizontal":
        for i, event in enumerate(events):
            event.x = i * (event.width + HORIZONTAL_SPACING)
            event.y = 0
    else:
        for i, event in enumerate(events):
            event.x = 0
            event.y = i * (event.height + VERTICAL_SPACING)
```

### Circular Layout

```python
def layout_circular(nodes, radius=500):
    n = len(nodes)
    angle_step = 2 * pi / n

    for i, node in enumerate(nodes):
        angle = i * angle_step
        node.x = radius * cos(angle) - node.width / 2
        node.y = radius * sin(angle) - node.height / 2
```

### Matrix Layout

```python
def layout_matrix(nodes, rows, cols):
    cell_width = 400
    cell_height = 250

    for i, node in enumerate(nodes):
        row = i // cols
        col = i % cols

        node.x = col * cell_width
        node.y = row * cell_height
```

## Quality Checks

Before finalizing layout, verify:

1. **No Overlaps**: All nodes have minimum spacing
2. **Balanced**: Visual center near (0, 0)
3. **Accessible**: All nodes reachable via edges
4. **Readable**: Text sizes appropriate for zoom level
5. **Efficient**: Edge paths reasonably direct
