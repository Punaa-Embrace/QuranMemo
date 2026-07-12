@extends('layouts.admin')

@section('content')
    <div>
        <div class="flex justify-between items-center mb-4">
            <h1 class="text-2xl font-bold text-gray-800">Manajemen User</h1>
            <button onclick="openModal()"
                class="bg-brand-600 hover:bg-brand-700 text-white px-4 py-2 rounded-xl text-sm">
                + Tambah User
            </button>
        </div>

        <!-- FILTER ROLE - DROPDOWN -->
        <div class="flex items-center space-x-4 mb-4">
            <label class="text-sm font-medium text-gray-700">Role:</label>
            <select onchange="window.location.href='{{ route('admin.users') }}?role='+this.value"
                class="px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500">
                <option value="all" {{ $role === 'all' ? 'selected' : '' }}>Semua Role</option>
                <option value="santri" {{ $role === 'santri' ? 'selected' : '' }}>Santri</option>
                <option value="ustad" {{ $role === 'ustad' ? 'selected' : '' }}>Ustad</option>
                <option value="orangtua" {{ $role === 'orangtua' ? 'selected' : '' }}>Orang Tua</option>
            </select>
            <span class="text-sm text-gray-500">Total: {{ $total[$role] ?? 0 }} user</span>
        </div>

        <!-- TABEL -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <table class="w-full">
                <thead class="bg-gray-50">
                    <tr>
                        @if($role === 'all')
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Nama</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Email</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Role</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Aksi</th>
                        @else
                            @foreach($fields as $field)
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">
                                    {{ strtoupper($field) }}</th>
                            @endforeach
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Role</th>
                            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase">Aksi</th>
                        @endif
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($data as $item)
                        <tr class="hover:bg-gray-50 transition">
                            @if($role === 'all')
                                <td class="px-6 py-4 font-medium">{{ $item->nama }}</td>
                                <td class="px-6 py-4 text-sm text-gray-600">{{ $item->email }}</td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full 
                                        {{ $item->role_display === 'santri' ? 'bg-brand-100 text-brand-700' : '' }}
                                        {{ $item->role_display === 'ustad' ? 'bg-blue-100 text-blue-700' : '' }}
                                        {{ $item->role_display === 'orangtua' ? 'bg-purple-100 text-purple-700' : '' }}">
                                        {{ ucfirst($item->role_display) }}
                                    </span>
                                </td>
                            @else
                                @foreach($fields as $field)
                                    <td class="px-6 py-4 text-sm">{{ $item->$field }}</td>
                                @endforeach
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 text-xs rounded-full bg-brand-100 text-brand-700">
                                        {{ ucfirst($role) }}
                                    </span>
                                </td>
                            @endif
                            <td class="px-6 py-4">
                                <div class="flex space-x-2">
                                    <button onclick="editUser('{{ $item->id }}', '{{ $item->nama }}', '{{ $item->email }}')"
                                        class="text-blue-600 hover:bg-blue-50 px-3 py-1 rounded-lg text-sm transition">Edit</button>

                                    <form method="POST"
                                        action="{{ route('admin.users.destroy', ['role' => $role, 'id' => $item->id]) }}"
                                        onsubmit="return confirm('Hapus user ini?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit"
                                            class="text-red-600 hover:bg-red-50 px-3 py-1 rounded-lg text-sm transition">Hapus</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-6 py-4 text-center text-gray-500">
                                <div class="flex flex-col items-center justify-center py-8">
                                    <svg class="w-12 h-12 text-gray-300 mb-3" fill="none" stroke="currentColor"
                                        viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                                    </svg>
                                    <span>Belum ada data</span>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL TAMBAH / EDIT -->
    <div id="modalUser" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
        <div class="bg-white rounded-2xl w-full max-w-md p-6">
            <div class="flex justify-between items-center mb-4">
                <h2 id="modalTitle" class="text-xl font-bold text-gray-800">Tambah User</h2>
                <button onclick="closeModal()" class="text-gray-400 hover:text-gray-600"></button>
            </div>

            <form id="formUser" method="POST">
                @csrf
                <input type="hidden" id="methodField" name="_method" value="POST">
                <input type="hidden" id="formRole" name="role" value="{{ $role === 'all' ? 'santri' : $role }}">

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                        <select id="roleSelect" onchange="updateFormRole()"
                            class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500">
                            <option value="santri">Santri</option>
                            <option value="ustad">Ustad</option>
                            <option value="orangtua">Orang Tua</option>
                        </select>
                    </div>

                    <div id="uniqueFieldWrapper">
                        <label class="block text-sm font-medium text-gray-700 mb-1" id="uniqueLabel">NIM</label>
                        <input type="text" id="unique_field" name="nim"
                            class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Nama</label>
                        <input type="text" id="nama" name="nama"
                            class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500"
                            required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <input type="email" id="email" name="email"
                            class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500"
                            required>
                    </div>
                    <div id="passwordInfo" class="text-sm text-gray-500 bg-gray-50 p-3 rounded-lg">
                        ️ Password default: <strong>password123</strong>
                    </div>
                    <button type="submit"
                        class="w-full bg-brand-600 hover:bg-brand-700 text-white py-2 rounded-lg font-semibold">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function updateFormRole() {
            const role = document.getElementById('roleSelect').value;
            document.getElementById('formRole').value = role;
            toggleUniqueField();
        }

        function toggleUniqueField() {
            const role = document.getElementById('roleSelect').value;
            const wrapper = document.getElementById('uniqueFieldWrapper');
            const label = document.getElementById('uniqueLabel');
            const input = document.getElementById('unique_field');

            if (role === 'santri') {
                wrapper.style.display = 'block';
                label.textContent = 'NIM';
                input.name = 'nim';
                input.placeholder = 'Masukkan NIM';
                input.required = true;
            } else if (role === 'ustad') {
                wrapper.style.display = 'block';
                label.textContent = 'NIK';
                input.name = 'nik';
                input.placeholder = 'Masukkan NIK';
                input.required = true;
            } else {
                wrapper.style.display = 'none';
                input.name = 'dummy';
                input.required = false;
            }
        }

        function openModal() {
            document.getElementById('modalUser').classList.remove('hidden');
            document.getElementById('modalUser').classList.add('flex');
            document.getElementById('formUser').reset();

            let defaultRole = '{{ $role }}';
            if (defaultRole === 'all') defaultRole = 'santri';

            document.getElementById('formUser').action = "{{ route('admin.users.store', ['role' => ':role']) }}".replace(':role', defaultRole);
            document.getElementById('methodField').value = 'POST';
            document.getElementById('modalTitle').textContent = 'Tambah User';
            document.getElementById('passwordInfo').style.display = 'block';

            document.getElementById('roleSelect').value = defaultRole;
            document.getElementById('formRole').value = defaultRole;
            toggleUniqueField();

            document.getElementById('nama').value = '';
            document.getElementById('email').value = '';
            document.getElementById('unique_field').disabled = false;
            document.getElementById('unique_field').value = '';
        }

        function closeModal() {
            document.getElementById('modalUser').classList.add('hidden');
            document.getElementById('modalUser').classList.remove('flex');
            document.getElementById('formUser').reset();
        }

        function editUser(id, nama, email) {
            openModal();
            document.getElementById('modalTitle').textContent = 'Edit User';

            let defaultRole = '{{ $role }}';
            if (defaultRole === 'all') defaultRole = 'santri';

            var form = document.getElementById('formUser');
            form.action = "{{ route('admin.users.update', ['role' => ':role', 'id' => ':id']) }}".replace(':role', defaultRole).replace(':id', id);
            document.getElementById('methodField').value = 'PUT';

            document.getElementById('roleSelect').value = defaultRole;
            document.getElementById('formRole').value = defaultRole;
            toggleUniqueField();

            document.getElementById('nama').value = nama;
            document.getElementById('email').value = email;
            document.getElementById('passwordInfo').style.display = 'none';

            const uniqueField = document.getElementById('unique_field');
            uniqueField.value = 'Tidak bisa diubah';
            uniqueField.disabled = true;
        }

        document.getElementById('modalUser').addEventListener('click', function (e) {
            if (e.target === this) closeModal();
        });
    </script>
@endsection