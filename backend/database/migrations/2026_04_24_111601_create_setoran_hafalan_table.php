<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('setoran_hafalan', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('santri_ustad_id');

            $table->string('surat');
            $table->integer('ayat');
            $table->string('status');
            $table->string('feedback_tulisan')->nullable();
            $table->string('feedback_vn_path')->nullable();
            $table->string('video_path')->nullable();

            $table->foreign('santri_ustad_id')
                ->references('id')
                ->on('santri_ustad')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('setoran_hafalan');
    }
};