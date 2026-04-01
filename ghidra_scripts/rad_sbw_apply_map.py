# Apply map XML to the open Ghidra project.
# - Disassembles ranges with type="code" format="instructions"
# - Creates labeled byte arrays for all other non-code ranges
# Safe to rerun: existing correctly-named labels and data are preserved.
# @category rad_sbw
# @runtime Jython

import re
import xml.etree.ElementTree as ET

from ghidra.app.cmd.disassemble import DisassembleCommand
from ghidra.program.model.address import AddressSet
from ghidra.program.model.data import ArrayDataType, ByteDataType
from ghidra.program.model.symbol import SourceType


def sanitize(s):
    return re.sub(r'[^A-Za-z0-9]+', '_', s).strip('_')


def make_base_name(entry):
    parts = [sanitize(entry.get(f, '')) for f in ('type', 'format', 'comment')]
    return '_'.join(p for p in parts if p)


def label_matches_base(name, base):
    """True if name == base or name == base_N for some integer N."""
    if name == base:
        return True
    m = re.match(r'^(.+)_(\d+)$', name)
    return m is not None and m.group(1) == base


def find_unique_label(symbol_table, addr, base_name):
    """
    Return the unique label name to create at addr, or None if addr already
    has a label whose base matches base_name (no action needed).
    """
    for sym in symbol_table.getSymbols(addr):
        if label_matches_base(sym.getName(), base_name):
            return None  # already correctly labeled

    candidate = base_name
    n = 2
    while True:
        it = symbol_table.getSymbols(candidate)
        conflict = False
        while it.hasNext():
            if it.next().getAddress() != addr:
                conflict = True
                break
        if not conflict:
            return candidate
        candidate = '{}_{}'.format(base_name, n)
        n += 1


def ensure_byte_array(listing, start_addr, end_addr_inclusive, length):
    """
    Ensure a byte array of the given length exists at start_addr.
    Clears conflicting code units if needed. Returns True on success.
    """
    existing = listing.getDataAt(start_addr)
    if existing is not None and existing.getLength() == length:
        return True  # already defined with correct size
    listing.clearCodeUnits(start_addr, end_addr_inclusive, False)
    try:
        listing.createData(start_addr, ArrayDataType(ByteDataType.dataType, length, 1))
        return True
    except Exception as e:
        printerr('  Could not create data at {}: {}'.format(start_addr, e))
        return False


def run():
    xml_file = askFile('Select map XML file', 'Apply')
    if xml_file is None:
        return

    tree = ET.parse(xml_file.getAbsolutePath())
    root = tree.getroot()

    addr_space = currentProgram.getAddressFactory().getDefaultAddressSpace()
    listing = currentProgram.getListing()
    symbol_table = currentProgram.getSymbolTable()

    disasm_set = AddressSet()
    n_created = 0
    n_skipped = 0

    for entry in root.iter('entry'):
        type_ = entry.get('type', '')
        fmt = entry.get('format', '')
        begin = int(entry.get('begin'), 16)
        end = int(entry.get('end'), 16)
        if begin >= end:
            continue

        start_addr = addr_space.getAddress(begin)
        end_addr = addr_space.getAddress(end - 1)
        length = end - begin

        if type_ == 'code' and fmt == 'instructions':
            disasm_set.addRange(start_addr, end_addr)
            continue

        if type_ == 'code':
            # Processor definition handles labels in code regions.
            continue

        base_name = make_base_name(entry)
        label_name = find_unique_label(symbol_table, start_addr, base_name)

        if label_name is None:
            # Label already correct; still make sure data is defined.
            ensure_byte_array(listing, start_addr, end_addr, length)
            n_skipped += 1
        else:
            if ensure_byte_array(listing, start_addr, end_addr, length):
                symbol_table.createLabel(start_addr, label_name, SourceType.USER_DEFINED)
                n_created += 1

    print('Data: {} created, {} already labeled.'.format(n_created, n_skipped))

    if not disasm_set.isEmpty():
        print('Disassembling {} code range(s)...'.format(disasm_set.getNumAddressRanges()))
        DisassembleCommand(disasm_set, None, True).applyTo(currentProgram, monitor)

    print('Done.')

if __name__ == "__main__":
    run()
