package main

import "core:fmt"

width: int = 10
height: int = 5

heat: []int
next_heat: []int

init_heat :: proc() {
	heat = make([]int, width * height)
	next_heat = make([]int, width * height)
}

get_index_from_coords :: proc(x: int, y: int) -> int {
	return y * width + x
}

clear_screen :: proc() {
	// Clear the Screen
	fmt.print("\x1b[2J")
	// Move Cursor Back to the top
	fmt.print("\x1b[H")
}

write :: proc(buffer: []int, x: int, y: int, val: int) {
	index: int = get_index_from_coords(x, y)
	buffer[index] = val
}

display_heat :: proc() {
	for y := 0; y < height; y += 1 {
		for x := 0; x < width; x += 1 {
			fmt.printf("%3d ", heat[get_index_from_coords(x, y)])
		}
		fmt.println()
	}
}

update_heat :: proc() {
	// Make the bottom row 99 always (fire source)
	for x := 0; x < width; x += 1 {
		index: int = get_index_from_coords(x, height - 1)
		next_heat[index] = 99
	}

	// Calculate the values of upper rows from lower rows
	for y := height - 2; y >= 0; y -= 1 {
		// We need to propagate upward, the average of the 3 direct cells right below
		sum: int = 0
		n: int = 0

		for x := 0; x < width; x += 1 {
			sum += heat[get_index_from_coords(x, y + 1)]
			n += 1

			if x != 0 {
				sum += heat[get_index_from_coords(x - 1, y + 1)]
				n += 1
			}

			if x != width - 1 {
				sum += heat[get_index_from_coords(x + 1, y + 1)]
				n += 1
			}

			new_val: int = sum / n

			// Assign new average to the top row cell
			next_heat[get_index_from_coords(x, y)] = new_val
		}
	}

	// Swap the buffers
	temp := heat
	heat = next_heat
	next_heat = temp
}

main :: proc() {
	// Initialize Heat Buffer
	init_heat()

	// Make the bottom row be the hottest
	for x := 0; x < width; x += 1 {
		write(heat, x, height - 1, 99)
	}

	// Play the fire animation
	for frame := 0; frame < 5; frame += 1 {
		clear_screen()
		display_heat()
		update_heat()
	}
}
