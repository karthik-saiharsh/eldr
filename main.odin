package main

import "core:fmt"
import "core:math/rand"

width: int = 30
height: int = 30
cooling: int = 5
spread: int = 3
rand_min: int = -5
rand_max: int = 5

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
			num: int = heat[get_index_from_coords(x, y)]
			fmt.printf("%c ", get_display_char(num))
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

		for x := 0; x < width; x += 1 {

			offset: int = rand.int_max(spread - (-spread) + 1) + (-spread)

			// We need to propagate upward, the average of the 3 direct cells right below
			sum: int = 0
			n: int = 0

			sample_x: int = x + offset
			sample_x = min(width - 1, max(0, sample_x))

			sum += heat[get_index_from_coords(min(width - 1, max(0, sample_x)), y + 1)]
			n += 1

			if sample_x > 0 {
				sum += heat[get_index_from_coords(sample_x - 1, y + 1)]
				n += 1
			}

			if sample_x < width - 1 {
				sum += heat[get_index_from_coords(sample_x + 1, y + 1)]
				n += 1
			}

			new_val: int = sum / n - cooling
			rand_no: int = rand.int_max(rand_max - rand_min + 1) + rand_min
			new_val += rand_no

			if new_val < 0 {
				new_val = 0
			}

			// Assign new average to the top row cell
			next_heat[get_index_from_coords(x, y)] = new_val
		}
	}

	// Swap the buffers
	temp := heat
	heat = next_heat
	next_heat = temp
}

get_display_char :: proc(num: int) -> rune {
	if num == 0 {
		return ' '
	} else if num >= 1 && num <= 15 {
		return '.'
	} else if num >= 16 && num <= 30 {
		return ':'
	} else if num >= 31 && num <= 45 {
		return '*'
	} else if num >= 46 && num <= 60 {
		return 'o'
	} else if num >= 61 && num <= 75 {
		return 'O'
	} else if num >= 76 && num <= 90 {
		return '#'
	} else {
		return '@'
	}
}

main :: proc() {
	// Initialize Heat Buffer
	init_heat()

	// Make the bottom row be the hottest
	for x := 0; x < width; x += 1 {
		write(heat, x, height - 1, 99)
	}

	// Play the fire animation
	for x := 0; x < 100; x += 1 {
		clear_screen()
		display_heat()
		update_heat()
	}
}
